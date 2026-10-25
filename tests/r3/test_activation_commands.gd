extends RefCounted
## C2 tests for atomic activation consumption, casualties, and explicit round transitions.

const BattleStateScript = preload("res://scripts/r3/battle_state.gd")
const SchedulerScript = preload("res://scripts/r3/activation_scheduler.gd")
const ServiceScript = preload("res://scripts/r3/activation_command_service.gd")
const SchedulerResultScript = preload("res://scripts/r3/activation_scheduler_result.gd")
const CommandResultScript = preload("res://scripts/r3/activation_command_result.gd")
const TransitionResultScript = preload("res://scripts/r3/battle_transition_result.gd")

var _checks: int = 0
var _failures: PackedStringArray = []
var _service: ActivationCommandService
var _scheduler: ActivationScheduler

func run() -> Dictionary:
	_service = ServiceScript.new()
	_scheduler = SchedulerScript.new()
	_test_reference_calendars_through_authoritative_commands()
	_test_invalid_and_duplicate_activation_commands()
	_test_domain_result_mapping_and_dependency_direction()
	_test_casualty_transitions()
	_test_explicit_next_round_transitions()
	return {"checks": _checks, "failures": _failures}

func _test_reference_calendars_through_authoritative_commands() -> void:
	var cases: Array[Dictionary] = [
		{"a": 1, "b": 1, "priority_a": "AB", "priority_b": "BA"},
		{"a": 4, "b": 4, "priority_a": "ABABABAB", "priority_b": "BABABABA"},
		{"a": 12, "b": 4, "priority_a": "AABAAABAAABAAABA", "priority_b": "ABAAABAAABAAABAA"},
		{"a": 7, "b": 4, "priority_a": "ABAABABAABA", "priority_b": "ABAABABAABA"},
		{"a": 5, "b": 3, "priority_a": "ABAABABA", "priority_b": "ABABAABA"},
		{"a": 12, "b": 7, "priority_a": "ABAABABAABAABABAABA", "priority_b": "ABAABABAABAABABAABA"},
		{"a": 1, "b": 8, "priority_a": "BBBBABBBB", "priority_b": "BBBBABBBB"},
		{"a": 0, "b": 5, "priority_a": "BBBBB", "priority_b": "BBBBB"},
		{"a": 5, "b": 0, "priority_a": "AAAAA", "priority_b": "AAAAA"},
		{"a": 0, "b": 0, "priority_a": "", "priority_b": ""},
	]
	for fixture in cases:
		for priority in [&"A", &"B"]:
			var expected: String = fixture["priority_a"] if priority == &"A" else fixture["priority_b"]
			var outcome: Dictionary = _simulate_with_commands(int(fixture["a"]), int(fixture["b"]), priority)
			_expect_equal(outcome["sequence"], expected,
				"authoritative command path must preserve SWRR calendar %d:%d priority %s" % [fixture["a"], fixture["b"], priority])
			_expect(bool(outcome["closed"]), "authoritative calendar must end in ROUND_COMPLETE")
			_expect_equal(outcome["accepted_count"], int(fixture["a"]) + int(fixture["b"]),
				"each roster unit must consume exactly one ordinary activation")
			_expect_equal(outcome["unique_units"], outcome["accepted_count"],
				"no unit may consume two ordinary activations in one round")

func _test_invalid_and_duplicate_activation_commands() -> void:
	var state := _make_state(1, 1, &"A")
	var permission: ActivationSchedulerResult = _scheduler.peek(state.scheduler_snapshot())
	_expect_equal(permission.acting_side, &"A", "1:1 priority A must initially grant A")
	_expect_rejected_consume(state, "B-0", permission.permission_id, 1,
		CommandResultScript.Status.WRONG_SIDE, "wrong-side unit")
	_expect_rejected_consume(state, "missing", permission.permission_id, 1,
		CommandResultScript.Status.UNKNOWN_UNIT, "unknown unit")
	_expect_rejected_consume(state, "A-0", "", 1,
		CommandResultScript.Status.INVALID_PERMISSION, "empty permission")
	_expect_rejected_consume(state, "A-0", permission.permission_id, 2,
		CommandResultScript.Status.STALE_PERMISSION, "wrong round")
	_expect_equal(_service.consume_ordinary_activation(null, "A-0", "x", 1).status,
		CommandResultScript.Status.INVALID_STATE, "null state must fail with a typed result")

	var before_revision: int = state.revision()
	var applied: ActivationCommandResult = _service.consume_ordinary_activation(
		state, "A-0", permission.permission_id, 1)
	_expect_equal(applied.status, CommandResultScript.Status.APPLIED, "valid activation must commit")
	_expect_equal(state.revision(), before_revision + 1, "successful activation increments revision once")
	_expect(state.unit_has_ordinary_activation_used("A-0"), "success records unit activation exactly once")
	_expect_rejected_consume(state, "B-0", permission.permission_id, 1,
		CommandResultScript.Status.STALE_PERMISSION, "reusing consumed permission")

	var next_permission: ActivationSchedulerResult = _scheduler.peek(state.scheduler_snapshot())
	_expect_equal(next_permission.acting_side, &"B", "1:1 must now grant B")
	_expect_rejected_consume(state, "A-0", next_permission.permission_id, 1,
		CommandResultScript.Status.ACTIVATION_ALREADY_USED, "already-consumed unit under current permission")

	var casualty_state := _make_state(1, 1, &"A")
	var old_permission: ActivationSchedulerResult = _scheduler.peek(casualty_state.scheduler_snapshot())
	var casualty: ActivationCommandResult = _service.record_casualty(
		casualty_state, "B-0", casualty_state.round_id(), casualty_state.revision())
	_expect_equal(casualty.status, CommandResultScript.Status.APPLIED, "logical casualty should commit")
	_expect_rejected_consume(casualty_state, "A-0", old_permission.permission_id, 1,
		CommandResultScript.Status.STALE_PERMISSION, "casualty invalidates earlier permission")
	var current: ActivationSchedulerResult = _scheduler.peek(casualty_state.scheduler_snapshot())
	_expect_rejected_consume(casualty_state, "B-0", current.permission_id, 1,
		CommandResultScript.Status.UNIT_DEAD, "dead unit must not receive an activation")

	var complete_state := _make_state(1, 0, &"A")
	var only_permission: ActivationSchedulerResult = _scheduler.peek(complete_state.scheduler_snapshot())
	_expect(_service.consume_ordinary_activation(complete_state, "A-0", only_permission.permission_id, 1).is_applied(),
		"last ordinary activation should commit")
	var complete_before: Dictionary = complete_state.to_checkpoint()
	_expect_rejected_consume(complete_state, "A-0", "non-empty", 1,
		CommandResultScript.Status.ROUND_COMPLETE, "completed round has no permission")
	_expect_equal(complete_state.to_checkpoint(), complete_before,
		"round-complete rejection must preserve full state")

func _test_domain_result_mapping_and_dependency_direction() -> void:
	var mappings: Array[Dictionary] = [
		{"domain": TransitionResultScript.Status.APPLIED, "application": CommandResultScript.Status.APPLIED},
		{"domain": TransitionResultScript.Status.INVALID_STATE, "application": CommandResultScript.Status.INVALID_STATE},
		{"domain": TransitionResultScript.Status.STALE_PERMISSION, "application": CommandResultScript.Status.STALE_PERMISSION},
		{"domain": TransitionResultScript.Status.UNKNOWN_UNIT, "application": CommandResultScript.Status.UNKNOWN_UNIT},
		{"domain": TransitionResultScript.Status.UNIT_DEAD, "application": CommandResultScript.Status.UNIT_DEAD},
		{"domain": TransitionResultScript.Status.UNIT_NOT_IN_ROSTER, "application": CommandResultScript.Status.UNIT_NOT_IN_ROSTER},
		{"domain": TransitionResultScript.Status.ACTIVATION_ALREADY_USED,
			"application": CommandResultScript.Status.ACTIVATION_ALREADY_USED},
		{"domain": TransitionResultScript.Status.WRONG_SIDE, "application": CommandResultScript.Status.WRONG_SIDE},
		{"domain": TransitionResultScript.Status.REVISION_EXHAUSTED,
			"application": CommandResultScript.Status.REVISION_EXHAUSTED},
		{"domain": TransitionResultScript.Status.STALE_STATE, "application": CommandResultScript.Status.STALE_STATE},
		{"domain": TransitionResultScript.Status.UNIT_ALREADY_DEAD,
			"application": CommandResultScript.Status.UNIT_ALREADY_DEAD},
		{"domain": TransitionResultScript.Status.ROUND_NOT_COMPLETE,
			"application": CommandResultScript.Status.ROUND_NOT_COMPLETE},
		{"domain": TransitionResultScript.Status.ROUND_ID_EXHAUSTED,
			"application": CommandResultScript.Status.ROUND_ID_EXHAUSTED},
	]
	for mapping in mappings:
		var domain_result := TransitionResultScript.new(mapping["domain"], &"mapping_check", 9, 17)
		var public_result: ActivationCommandResult = _service._map_domain_result(domain_result)
		_expect_equal(public_result.status, mapping["application"],
			"domain status maps explicitly to unchanged public command status")
		_expect_equal(public_result.error_code, &"mapping_check", "status mapping preserves error code")
		_expect_equal(public_result.round_id, 9, "status mapping preserves round ID")
		_expect_equal(public_result.state_revision, 17, "status mapping preserves revision")
	var missing: ActivationCommandResult = _service._map_domain_result(null)
	_expect_equal(missing.status, CommandResultScript.Status.INVALID_STATE,
		"missing domain transition result must fail safely")
	_expect_equal(missing.error_code, &"missing_domain_transition_result",
		"missing domain result returns stable application error code")
	var unexpected_domain_result := TransitionResultScript.new(
		TransitionResultScript.Status.INVALID_STATE, &"unmapped", 9, 17)
	unexpected_domain_result.status = 999
	var fail_closed: ActivationCommandResult = _service._map_domain_result(unexpected_domain_result)
	_expect_equal(fail_closed.status, CommandResultScript.Status.INVALID_STATE,
		"unrecognized domain status must fail closed")
	_expect_equal(fail_closed.error_code, &"unmapped_domain_transition_status",
		"unrecognized domain status returns stable mapping error")
	_expect_equal(fail_closed.round_id, 9, "unrecognized mapping preserves round context")
	_expect_equal(fail_closed.state_revision, 17, "unrecognized mapping preserves revision context")
	var battle_state_source: String = FileAccess.get_file_as_string("res://scripts/r3/battle_state.gd")
	_expect(not battle_state_source.contains("ActivationCommandResult"),
		"BattleState domain source must not reference application result")
	_expect(not battle_state_source.contains("ActivationCommandService"),
		"BattleState domain source must not reference application service")

func _test_casualty_transitions() -> void:
	var state_7_4 := _make_state(7, 4, &"A")
	var initial_weights: Dictionary = state_7_4.scheduler_snapshot()["initial_weights"]
	var previous_permission: ActivationSchedulerResult = _scheduler.peek(state_7_4.scheduler_snapshot())
	var before_revision: int = state_7_4.revision()
	_expect_rejected_casualty(state_7_4, "B-0", 1, before_revision - 1,
		CommandResultScript.Status.STALE_STATE, "casualty stale revision")
	_expect_rejected_casualty(state_7_4, "B-0", 2, before_revision,
		CommandResultScript.Status.STALE_STATE, "casualty wrong round")
	var casualty: ActivationCommandResult = _service.record_casualty(
		state_7_4, "B-0", state_7_4.round_id(), state_7_4.revision())
	_expect_equal(casualty.status, CommandResultScript.Status.APPLIED, "7:4 pending-unit casualty must commit")
	_expect_state_invariants(state_7_4, "7:4 pre-activation casualty")
	_expect(not state_7_4.unit_has_ordinary_activation_used("B-0"),
		"casualty before acting must not count as consumed activation")
	_expect_equal(state_7_4.scheduler_snapshot()["initial_weights"], initial_weights,
		"casualty must not change frozen 7:4 weights")
	_expect_equal(state_7_4.revision(), before_revision + 1, "casualty advances state revision")
	_expect_rejected_consume(state_7_4, "A-0", previous_permission.permission_id, 1,
		CommandResultScript.Status.STALE_PERMISSION, "pending casualty invalidates old token")
	var reduced_calendar: Dictionary = _drain_round(state_7_4)
	_expect(bool(reduced_calendar["closed"]), "7:4 with a pending casualty must still terminate")
	_expect_equal(reduced_calendar["count_b"], 3, "7:4 casualty removes one B opportunity")
	_expect_equal(state_7_4.scheduler_snapshot()["initial_weights"], initial_weights,
		"weights remain frozen through the reduced 7:4 calendar")

	var state_12_4 := _make_state(12, 4, &"A")
	var permission: ActivationSchedulerResult = _scheduler.peek(state_12_4.scheduler_snapshot())
	_expect(_service.consume_ordinary_activation(state_12_4, "A-0", permission.permission_id, 1).is_applied(),
		"12:4 fixture first A activation should commit")
	var after_activation: Dictionary = state_12_4.scheduler_snapshot()
	var post_action_casualty: ActivationCommandResult = _service.record_casualty(
		state_12_4, "A-0", state_12_4.round_id(), state_12_4.revision())
	_expect_equal(post_action_casualty.status, CommandResultScript.Status.APPLIED,
		"post-activation casualty should commit")
	_expect_state_invariants(state_12_4, "12:4 post-activation casualty")
	_expect(state_12_4.unit_has_ordinary_activation_used("A-0"),
		"death after acting preserves the consumed-activation history")
	_expect_equal(state_12_4.scheduler_snapshot()["initial_weights"], after_activation["initial_weights"],
		"12:4 weights stay frozen after an acted unit dies")
	_expect_equal(state_12_4.scheduler_snapshot()["credits"], after_activation["credits"],
		"casualty must not consume or alter SWRR credits")
	_expect(bool(_drain_round(state_12_4)["closed"]), "12:4 with post-action casualty must terminate")

	var state_1_1 := _make_state(1, 1, &"A")
	var first: ActivationSchedulerResult = _scheduler.peek(state_1_1.scheduler_snapshot())
	_expect(_service.consume_ordinary_activation(state_1_1, "A-0", first.permission_id, 1).is_applied(),
		"1:1 first activation should commit")
	var last_b_permission: ActivationSchedulerResult = _scheduler.peek(state_1_1.scheduler_snapshot())
	var last_casualty: ActivationCommandResult = _service.record_casualty(
		state_1_1, "B-0", state_1_1.round_id(), state_1_1.revision())
	_expect_equal(last_casualty.status, CommandResultScript.Status.APPLIED,
		"last pending unit casualty should commit")
	_expect_state_invariants(state_1_1, "1:1 last pending casualty")
	_expect_equal(_scheduler.peek(state_1_1.scheduler_snapshot()).status,
		SchedulerResultScript.Status.ROUND_COMPLETE, "last eligible casualty closes round without ghost permit")
	_expect_rejected_consume(state_1_1, "B-0", last_b_permission.permission_id, 1,
		CommandResultScript.Status.ROUND_COMPLETE, "dead last unit cannot receive a ghost permit")
	_expect_equal(state_1_1.scheduler_snapshot()["initial_weights"], {&"A": 1, &"B": 1},
		"1:1 casualty keeps weights frozen until next round")

	var repeated_before: Dictionary = state_1_1.to_checkpoint()
	_expect_equal(_service.record_casualty(state_1_1, "B-0", 1, state_1_1.revision()).status,
		CommandResultScript.Status.UNIT_ALREADY_DEAD, "repeated casualty is rejected")
	_expect_equal(state_1_1.to_checkpoint(), repeated_before, "repeated casualty rejection is mutation-free")
	_expect_equal(_service.record_casualty(state_1_1, "missing", 1, state_1_1.revision()).status,
		CommandResultScript.Status.UNKNOWN_UNIT, "unknown casualty target is rejected")
	_expect_equal(state_1_1.to_checkpoint(), repeated_before, "unknown casualty rejection is mutation-free")

func _test_explicit_next_round_transitions() -> void:
	var both_alive := _make_state(1, 1, &"A")
	var incomplete_before: Dictionary = both_alive.to_checkpoint()
	var early_result: ActivationCommandResult = _service.begin_next_round(
		both_alive, 1, both_alive.revision())
	_expect_equal(early_result.status, CommandResultScript.Status.ROUND_NOT_COMPLETE,
		"cannot start next round early")
	_expect_equal(both_alive.to_checkpoint(), incomplete_before, "early-round rejection is mutation-free")
	_expect_equal(_drain_round(both_alive)["sequence"], "AB", "1:1 old round calendar remains stable")
	var old_revision: int = both_alive.revision()
	_expect_rejected_begin_round(both_alive, both_alive.round_id(), old_revision - 1,
		CommandResultScript.Status.STALE_STATE, "new round stale revision")
	_expect_rejected_begin_round(both_alive, both_alive.round_id() - 1, old_revision,
		CommandResultScript.Status.STALE_STATE, "new round wrong completed round")
	var next_result: ActivationCommandResult = _service.begin_next_round(
		both_alive, both_alive.round_id(), both_alive.revision())
	_expect_equal(next_result.status, CommandResultScript.Status.APPLIED, "complete round advances explicitly")
	_expect_state_invariants(both_alive, "both-survivor round transition")
	_expect_equal(both_alive.round_id(), 2, "next round ID increments")
	_expect_equal(both_alive.revision(), old_revision + 1, "global revision remains monotonic across rounds")
	_expect_equal(both_alive.priority_side(), &"B", "next round alternates tie-break priority")
	_expect_equal(both_alive.scheduler_snapshot()["credits"], {&"A": 0, &"B": 0},
		"next round resets credits")
	_expect_equal(both_alive.scheduler_snapshot()["pending_counts"], {&"A": 1, &"B": 1},
		"next round restores one activation for each survivor")
	var first_next: ActivationSchedulerResult = _scheduler.peek(both_alive.scheduler_snapshot())
	_expect_equal(first_next.acting_side, &"B", "alternated tie-break picks B on equal-weight next round")
	_expect(first_next.permission_id != "1:0:A", "new round permission cannot reuse old round ID")
	_expect_rejected_begin_round(both_alive, 1, old_revision,
		CommandResultScript.Status.STALE_STATE, "repeating an already-applied round transition")

	var one_side := _make_state(1, 1, &"A")
	_expect(_service.record_casualty(one_side, "A-0", 1, one_side.revision()).is_applied(),
		"one-side fixture casualty should commit")
	_expect(bool(_drain_round(one_side)["closed"]), "single surviving side can finish the round")
	_expect(_service.begin_next_round(one_side, one_side.round_id(), one_side.revision()).is_applied(),
		"survivor-only next round should start")
	_expect_state_invariants(one_side, "single-survivor round transition")
	_expect_equal(one_side.scheduler_snapshot()["initial_weights"], {&"A": 0, &"B": 1},
		"next round recalculates roster weights from surviving units")
	_expect_equal(one_side.scheduler_snapshot()["pending_counts"], {&"A": 0, &"B": 1},
		"dead unit receives no activation in the next round")

	var no_survivors := _make_state(1, 1, &"A")
	_expect(_service.record_casualty(no_survivors, "A-0", 1, no_survivors.revision()).is_applied(),
		"empty-roster A casualty should commit")
	_expect(_service.record_casualty(no_survivors, "B-0", 1, no_survivors.revision()).is_applied(),
		"empty-roster B casualty should commit")
	_expect_equal(_scheduler.peek(no_survivors.scheduler_snapshot()).status,
		SchedulerResultScript.Status.ROUND_COMPLETE, "no living units means complete, not victory/defeat")
	_expect(_service.begin_next_round(no_survivors, 1, no_survivors.revision()).is_applied(),
		"explicit empty next round must not loop or grant a permit")
	_expect_state_invariants(no_survivors, "zero-survivor round transition")
	_expect_equal(no_survivors.scheduler_snapshot()["initial_weights"], {&"A": 0, &"B": 0},
		"no-survivor next round has zero weights")
	_expect_equal(_scheduler.peek(no_survivors.scheduler_snapshot()).status,
		SchedulerResultScript.Status.ROUND_COMPLETE, "zero-versus-zero next round closes without a ghost permit")

func _simulate_with_commands(count_a: int, count_b: int, priority: StringName) -> Dictionary:
	var state := _make_state(count_a, count_b, priority)
	var initial_weights: Dictionary = state.scheduler_snapshot()["initial_weights"]
	var sequence: String = ""
	var accepted_units: Dictionary = {}
	var accepted_count: int = 0
	var guard: int = count_a + count_b + 1
	while guard > 0:
		guard -= 1
		var before: Dictionary = state.scheduler_snapshot()
		var permission: ActivationSchedulerResult = _scheduler.peek(before)
		if permission.status == SchedulerResultScript.Status.ROUND_COMPLETE:
			break
		if permission.status != SchedulerResultScript.Status.PERMISSION_AVAILABLE:
			_failures.append("valid authoritative simulation snapshot rejected: %s" % permission.error_code)
			break
		var eligible: Array[String] = state.eligible_unit_ids_for_side(permission.acting_side)
		_expect(not eligible.is_empty(), "permission side must expose at least one eligible unit")
		if eligible.is_empty():
			break
		var selected_id: String = eligible[0]
		_expect(not accepted_units.has(selected_id), "unit ID cannot receive a duplicate ordinary permission")
		var applied: ActivationCommandResult = _service.consume_ordinary_activation(
			state, selected_id, permission.permission_id, permission.round_id)
		_expect_equal(applied.status, CommandResultScript.Status.APPLIED,
			"valid SWRR permission must commit through application service")
		if not applied.is_applied():
			break
		accepted_units[selected_id] = true
		accepted_count += 1
		sequence += String(permission.acting_side)
		var after: Dictionary = state.scheduler_snapshot()
		_expect_equal(after["initial_weights"], initial_weights, "ordinary consumption must freeze round weights")
		_expect_equal(after["credits"][&"A"], permission.next_credit_a,
			"committed A credit must match scheduler proposal")
		_expect_equal(after["credits"][&"B"], permission.next_credit_b,
			"committed B credit must match scheduler proposal")
		_expect_equal(state.revision(), int(before["revision"]) + 1,
			"successful consumption advances revision exactly once")
		_expect_state_invariants(state, "ordinary activation")
	var final_query: ActivationSchedulerResult = _scheduler.peek(state.scheduler_snapshot())
	return {
		"sequence": sequence,
		"accepted_count": accepted_count,
		"unique_units": accepted_units.size(),
		"count_a": sequence.count("A"),
		"count_b": sequence.count("B"),
		"closed": final_query.status == SchedulerResultScript.Status.ROUND_COMPLETE
			and guard >= 0 and accepted_count == count_a + count_b,
	}

func _drain_round(state: BattleState) -> Dictionary:
	var sequence: String = ""
	var guard: int = state.unit_count() * 2 + 2
	while guard > 0:
		guard -= 1
		var permission: ActivationSchedulerResult = _scheduler.peek(state.scheduler_snapshot())
		if permission.status == SchedulerResultScript.Status.ROUND_COMPLETE:
			return {"sequence": sequence, "closed": true,
				"count_a": sequence.count("A"), "count_b": sequence.count("B")}
		if permission.status != SchedulerResultScript.Status.PERMISSION_AVAILABLE:
			_failures.append("round drain got invalid scheduler result: %s" % permission.error_code)
			break
		var eligible: Array[String] = state.eligible_unit_ids_for_side(permission.acting_side)
		if eligible.is_empty():
			_failures.append("scheduler granted a side with no eligible units")
			break
		var applied: ActivationCommandResult = _service.consume_ordinary_activation(
			state, eligible[0], permission.permission_id, permission.round_id)
		if not applied.is_applied():
			_failures.append("valid drain activation rejected: %s" % applied.error_code)
			break
		sequence += String(permission.acting_side)
		_expect_state_invariants(state, "round drain activation")
	return {"sequence": sequence, "closed": false,
		"count_a": sequence.count("A"), "count_b": sequence.count("B")}

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
		_failures.append("BattleState fixture failed: %s" % state.error_code())
	return state

func _expect_rejected_consume(state: BattleState, unit_id: String, permission_id: String,
		round_id: int, expected_status: ActivationCommandResult.Status, label: String) -> void:
	var before: Dictionary = state.to_checkpoint()
	var result: ActivationCommandResult = _service.consume_ordinary_activation(
		state, unit_id, permission_id, round_id)
	_expect_equal(result.status, expected_status, "%s must return the expected typed status" % label)
	_expect_equal(state.to_checkpoint(), before, "%s rejection must preserve full authoritative state" % label)

func _expect_rejected_casualty(state: BattleState, unit_id: String, round_id: int,
		expected_revision: int, expected_status: ActivationCommandResult.Status,
		label: String) -> void:
	var before: Dictionary = state.to_checkpoint()
	var result: ActivationCommandResult = _service.record_casualty(
		state, unit_id, round_id, expected_revision)
	_expect_equal(result.status, expected_status, "%s must reject with typed status" % label)
	_expect_equal(state.to_checkpoint(), before, "%s rejection must preserve complete state" % label)

func _expect_rejected_begin_round(state: BattleState, completed_round_id: int,
		expected_revision: int, expected_status: ActivationCommandResult.Status,
		label: String) -> void:
	var before: Dictionary = state.to_checkpoint()
	var result: ActivationCommandResult = _service.begin_next_round(
		state, completed_round_id, expected_revision)
	_expect_equal(result.status, expected_status, "%s must reject with typed status" % label)
	_expect_equal(state.to_checkpoint(), before, "%s rejection must preserve complete state" % label)

func _expect_state_invariants(state: BattleState, label: String) -> void:
	var checkpoint: Dictionary = state.to_checkpoint()
	var side_a := StringName(checkpoint["side_a"])
	var side_b := StringName(checkpoint["side_b"])
	var expected_weights: Dictionary = {side_a: 0, side_b: 0}
	var expected_pending: Dictionary = {side_a: 0, side_b: 0}
	var unit_sides: Array = checkpoint["unit_sides"]
	var alive: Array = checkpoint["unit_alive"]
	var in_roster: Array = checkpoint["unit_in_current_roster"]
	var used: Array = checkpoint["ordinary_activation_used"]
	for index in unit_sides.size():
		var unit_side := StringName(unit_sides[index])
		if in_roster[index]:
			expected_weights[unit_side] = int(expected_weights[unit_side]) + 1
		if alive[index] and in_roster[index] and not used[index]:
			expected_pending[unit_side] = int(expected_pending[unit_side]) + 1
	var snapshot: Dictionary = state.scheduler_snapshot()
	_expect_equal(snapshot["initial_weights"], expected_weights,
		"%s frozen weights must equal roster ledger" % label)
	_expect_equal(snapshot["pending_counts"], expected_pending,
		"%s pending counts must match unit ledger" % label)
	var query: ActivationSchedulerResult = _scheduler.peek(snapshot)
	_expect(query.status != SchedulerResultScript.Status.INVALID_STATE,
		"%s transition must leave scheduler-valid state" % label)

func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)

func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [message, expected, actual])
