extends RefCounted
## C2 checkpoint validation, replay, and deterministic continuation tests.

const BattleStateScript = preload("res://scripts/r3/battle_state.gd")
const SchedulerScript = preload("res://scripts/r3/activation_scheduler.gd")
const ServiceScript = preload("res://scripts/r3/activation_command_service.gd")
const SchedulerResultScript = preload("res://scripts/r3/activation_scheduler_result.gd")
const CommandResultScript = preload("res://scripts/r3/activation_command_result.gd")

var _checks: int = 0
var _failures: PackedStringArray = []
var _service: ActivationCommandService
var _scheduler: ActivationScheduler

func run() -> Dictionary:
	_service = ServiceScript.new()
	_scheduler = SchedulerScript.new()
	_test_checkpoint_continuation_and_replay()
	_test_reject_invalid_checkpoints_atomically()
	return {"checks": _checks, "failures": _failures}

func _test_checkpoint_continuation_and_replay() -> void:
	var first := _make_state(7, 4, &"A")
	var second := _make_state(7, 4, &"A")
	var first_trace: Array[String] = _run_known_activation_casualty_trace(first)
	var second_trace: Array[String] = _run_known_activation_casualty_trace(second)
	_expect_equal(first_trace, second_trace, "same initial state and commands must replay same event trace")
	_expect_equal(first.to_checkpoint(), second.to_checkpoint(),
		"replayed activation/casualty trace must produce identical full state")
	_expect_equal(_scheduler.peek(first.scheduler_snapshot()).permission_id,
		_scheduler.peek(second.scheduler_snapshot()).permission_id,
		"replayed state must produce the same next permission")

	var checkpoint: Dictionary = first.to_checkpoint()
	var restored: BattleState = BattleStateScript.restore_checkpoint(checkpoint.duplicate(true))
	_expect(restored.is_valid(), "valid mid-round checkpoint must restore")
	_expect_equal(restored.to_checkpoint(), checkpoint, "restore must preserve unit ledger, credits, roster and revision")
	var next_original: ActivationSchedulerResult = _scheduler.peek(first.scheduler_snapshot())
	var next_restored: ActivationSchedulerResult = _scheduler.peek(restored.scheduler_snapshot())
	_expect_equal(next_restored.permission_id, next_original.permission_id,
		"restored checkpoint must continue with identical permission ID")
	_expect_equal(next_restored.acting_side, next_original.acting_side,
		"restored checkpoint must continue with identical acting side")
	var continuation_a: Array[String] = _drain(first)
	var continuation_b: Array[String] = _drain(restored)
	_expect_equal(continuation_b, continuation_a, "restored checkpoint continuation must match original")
	_expect_equal(restored.to_checkpoint(), first.to_checkpoint(),
		"continuation must reach identical full state")
	_expect_equal(_scheduler.peek(restored.scheduler_snapshot()).status,
		SchedulerResultScript.Status.ROUND_COMPLETE, "continued checkpoint must close without ghost permit")

	var consumed_state := _make_state(1, 1, &"A")
	var consumed_permission: ActivationSchedulerResult = _scheduler.peek(consumed_state.scheduler_snapshot())
	_expect(_service.consume_ordinary_activation(consumed_state, "A-0",
		consumed_permission.permission_id, 1).is_applied(), "consumption checkpoint fixture should advance")
	_assert_valid_checkpoint(consumed_state.to_checkpoint(), "after ordinary activation")
	var casualty_state := _make_state(1, 1, &"A")
	_expect(_service.record_casualty(casualty_state, "B-0", 1, casualty_state.revision()).is_applied(),
		"casualty checkpoint fixture should advance")
	_assert_valid_checkpoint(casualty_state.to_checkpoint(), "after pre-activation casualty")
	var acted_then_killed := _make_state(1, 1, &"A")
	var acted_permission: ActivationSchedulerResult = _scheduler.peek(acted_then_killed.scheduler_snapshot())
	_expect(_service.consume_ordinary_activation(acted_then_killed, "A-0",
		acted_permission.permission_id, 1).is_applied(), "acted-then-killed fixture activation should commit")
	var acted_credits: Dictionary = acted_then_killed.scheduler_snapshot()["credits"]
	_expect(_service.record_casualty(acted_then_killed, "A-0", 1,
		acted_then_killed.revision()).is_applied(), "casualty of acted unit should commit")
	var acted_then_killed_checkpoint: Dictionary = acted_then_killed.to_checkpoint()
	var restored_acted_then_killed: BattleState = BattleStateScript.restore_checkpoint(
		acted_then_killed_checkpoint.duplicate(true))
	_expect(restored_acted_then_killed.is_valid(),
		"checkpoint with consumed activation followed by casualty must restore")
	_expect_equal(restored_acted_then_killed.to_checkpoint(), acted_then_killed_checkpoint,
		"acted-then-killed restore preserves both represented transitions")
	_expect_equal(restored_acted_then_killed.revision(), 2,
		"acted-then-killed checkpoint preserves both revisions")
	_expect_equal(restored_acted_then_killed.scheduler_snapshot()["credits"], acted_credits,
		"casualty after activation checkpoint preserves credits from the consumed permission")
	var next_round_state := _make_state(1, 1, &"A")
	_expect(_service.record_casualty(next_round_state, "A-0", 1,
		next_round_state.revision()).is_applied(), "survivor-roster fixture casualty should commit")
	_drain(next_round_state)
	_expect(_service.begin_next_round(next_round_state, next_round_state.round_id(),
		next_round_state.revision()).is_applied(), "new-round checkpoint fixture should advance")
	var next_round_checkpoint: Dictionary = next_round_state.to_checkpoint()
	var restored_next_round: BattleState = BattleStateScript.restore_checkpoint(next_round_checkpoint.duplicate(true))
	_expect(restored_next_round.is_valid(), "checkpoint after new-round transition must restore")
	_expect_equal(restored_next_round.to_checkpoint(), next_round_checkpoint,
		"new-round restore preserves complete survivor roster state")
	_expect_equal(restored_next_round.scheduler_snapshot()["initial_weights"], {&"A": 0, &"B": 1},
		"new-round restore preserves recalculated survivor weights")
	_expect_equal(restored_next_round.to_checkpoint()["round_start_revision"],
		next_round_state.to_checkpoint()["round_start_revision"],
		"new-round restore preserves the transition boundary revision")
	_expect_equal(restored_next_round.priority_side(), &"B",
		"new-round restore preserves alternating tie-break priority")

	var detached: Dictionary = first.to_checkpoint()
	(detached["unit_ids"] as Array)[0] = "tampered"
	(detached["credits"] as Dictionary)["A"] = 1000
	_expect_equal(first.to_checkpoint(), restored.to_checkpoint(),
		"checkpoint export must be detached from authoritative state")
	_expect_equal(first.to_checkpoint()["unit_ids"][0], "A-0",
		"mutating exported checkpoint must not alter unit IDs")

func _test_reject_invalid_checkpoints_atomically() -> void:
	var original := _make_state(2, 1, &"B")
	var checkpoint: Dictionary = original.to_checkpoint()
	var invalid_fixtures: Array[Dictionary] = []
	var missing_key: Dictionary = checkpoint.duplicate(true)
	missing_key.erase("credits")
	invalid_fixtures.append(missing_key)
	var duplicate_id: Dictionary = checkpoint.duplicate(true)
	duplicate_id["unit_ids"][1] = duplicate_id["unit_ids"][0]
	invalid_fixtures.append(duplicate_id)
	var mismatched_roster: Dictionary = checkpoint.duplicate(true)
	mismatched_roster["initial_weights"]["A"] = 99
	invalid_fixtures.append(mismatched_roster)
	var invalid_credit: Dictionary = checkpoint.duplicate(true)
	invalid_credit["credits"]["A"] = 200001
	invalid_fixtures.append(invalid_credit)
	var invalid_side: Dictionary = checkpoint.duplicate(true)
	invalid_side["unit_sides"][0] = "C"
	invalid_fixtures.append(invalid_side)
	var invalid_length: Dictionary = checkpoint.duplicate(true)
	invalid_length["ordinary_activation_used"].pop_back()
	invalid_fixtures.append(invalid_length)
	var invalid_flags: Dictionary = checkpoint.duplicate(true)
	var malformed_alive: Array = []
	for alive_flag in checkpoint["unit_alive"]:
		malformed_alive.append(alive_flag)
	malformed_alive[0] = "alive"
	invalid_flags["unit_alive"] = malformed_alive
	invalid_fixtures.append(invalid_flags)
	# Use a self-consistent 1:1 roster for the postcondition-boundary fixture.
	var boundary_state := _make_state(1, 1, &"A")
	var boundary: Dictionary = boundary_state.to_checkpoint()
	boundary["credits"]["A"] = -200000
	boundary["credits"]["B"] = -200000
	invalid_fixtures.append(boundary)
	var zero_sum_nonzero_credits: Dictionary = boundary_state.to_checkpoint()
	zero_sum_nonzero_credits["credits"]["A"] = -1
	zero_sum_nonzero_credits["credits"]["B"] = 1
	invalid_fixtures.append(zero_sum_nonzero_credits)
	var nonzero_credit_sum: Dictionary = boundary_state.to_checkpoint()
	nonzero_credit_sum["credits"]["A"] = 1
	nonzero_credit_sum["credits"]["B"] = 0
	invalid_fixtures.append(nonzero_credit_sum)
	var revision_zero_consumed: Dictionary = boundary_state.to_checkpoint()
	revision_zero_consumed["ordinary_activation_used"][0] = true
	invalid_fixtures.append(revision_zero_consumed)
	var revision_zero_dead: Dictionary = boundary_state.to_checkpoint()
	revision_zero_dead["unit_alive"][0] = false
	invalid_fixtures.append(revision_zero_dead)
	var unrepresented_revision: Dictionary = boundary_state.to_checkpoint()
	unrepresented_revision["revision"] = 1
	invalid_fixtures.append(unrepresented_revision)

	var original_before: Dictionary = original.to_checkpoint()
	for index in invalid_fixtures.size():
		var fixture: Dictionary = invalid_fixtures[index]
		var fixture_before: Dictionary = fixture.duplicate(true)
		var rejected: BattleState = BattleStateScript.restore_checkpoint(fixture)
		_expect(not rejected.is_valid(), "invalid checkpoint %d must not restore" % index)
		_expect_equal(rejected.error_code(), &"invalid_checkpoint",
			"invalid checkpoint %d must return explicit error" % index)
		_expect_equal(rejected.scheduler_snapshot(), {},
			"invalid checkpoint %d must expose no partially restored scheduler state" % index)
		_expect_equal(fixture, fixture_before, "restore must not mutate input checkpoint")
	_expect_equal(original.to_checkpoint(), original_before,
		"invalid restore attempts must not mutate an existing live state")
	var rejected_null: BattleState = BattleStateScript.restore_checkpoint(null)
	_expect(not rejected_null.is_valid(), "null checkpoint must fail without a runtime type error")
	_expect_equal(rejected_null.error_code(), &"invalid_checkpoint", "null checkpoint has typed failure")

func _assert_valid_checkpoint(checkpoint: Dictionary, label: String) -> void:
	var restored: BattleState = BattleStateScript.restore_checkpoint(checkpoint.duplicate(true))
	_expect(restored.is_valid(), "%s must remain restorable" % label)
	_expect_equal(restored.to_checkpoint(), checkpoint, "%s must round-trip its full current ledger" % label)

func _run_known_activation_casualty_trace(state: BattleState) -> Array[String]:
	var trace: Array[String] = []
	var first: ActivationSchedulerResult = _scheduler.peek(state.scheduler_snapshot())
	_expect_equal(first.acting_side, &"A", "7:4 priority A trace begins with A")
	var first_ids: Array[String] = state.eligible_unit_ids_for_side(first.acting_side)
	var first_result: ActivationCommandResult = _service.consume_ordinary_activation(
		state, first_ids[0], first.permission_id, first.round_id)
	_expect(first_result.is_applied(), "known trace first activation should apply")
	trace.append("activate:%s:%s" % [first.acting_side, first_ids[0]])
	var second: ActivationSchedulerResult = _scheduler.peek(state.scheduler_snapshot())
	_expect_equal(second.acting_side, &"B", "7:4 known trace then grants B")
	var casualty: ActivationCommandResult = _service.record_casualty(
		state, "B-0", state.round_id(), state.revision())
	_expect(casualty.is_applied(), "known trace pending B casualty should apply")
	trace.append("casualty:B-0")
	var drain_trace: Array[String] = _drain(state)
	trace.append_array(drain_trace)
	return trace

func _drain(state: BattleState) -> Array[String]:
	var trace: Array[String] = []
	var guard: int = state.unit_count() * 2 + 2
	while guard > 0:
		guard -= 1
		var permission: ActivationSchedulerResult = _scheduler.peek(state.scheduler_snapshot())
		if permission.status == SchedulerResultScript.Status.ROUND_COMPLETE:
			return trace
		if permission.status != SchedulerResultScript.Status.PERMISSION_AVAILABLE:
			_failures.append("checkpoint replay scheduler failed: %s" % permission.error_code)
			return trace
		var units: Array[String] = state.eligible_unit_ids_for_side(permission.acting_side)
		if units.is_empty():
			_failures.append("checkpoint replay returned permission with no eligible unit")
			return trace
		var result: ActivationCommandResult = _service.consume_ordinary_activation(
			state, units[0], permission.permission_id, permission.round_id)
		if not result.is_applied():
			_failures.append("checkpoint replay command rejected: %s" % result.error_code)
			return trace
		trace.append("activate:%s:%s" % [permission.acting_side, units[0]])
	_failures.append("checkpoint replay exceeded its finite permit guard")
	return trace

func _make_state(count_a: int, count_b: int, priority: StringName) -> BattleState:
	var ids: Array[String] = []
	var sides: Array[StringName] = []
	for index in count_a:
		ids.append("A-%d" % index)
		sides.append(&"A")
	for index in count_b:
		ids.append("B-%d" % index)
		sides.append(&"B")
	var state := BattleStateScript.new()
	if not state.configure_round(ids, sides, &"A", &"B", priority, 1):
		_failures.append("checkpoint fixture failed: %s" % state.error_code())
	return state

func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)

func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [message, expected, actual])
