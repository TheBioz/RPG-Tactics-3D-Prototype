extends RefCounted
## C1 tests for deterministic, non-mutating SWRR permissions and round closure.

const BattleStateScript = preload("res://scripts/r3/battle_state.gd")
const SchedulerScript = preload("res://scripts/r3/activation_scheduler.gd")
const ResultScript = preload("res://scripts/r3/activation_scheduler_result.gd")

var _checks: int = 0
var _failures: PackedStringArray = []

func run() -> Dictionary:
	_test_reference_sequences()
	_test_exact_reference_metrics()
	_test_query_is_repeatable_and_non_mutating()
	_test_snapshot_is_detached()
	_test_roster_validation()
	_test_roster_reconfiguration_is_rejected()
	_test_empty_round_and_invalid_snapshot()
	return {"checks": _checks, "failures": _failures}

func _test_reference_sequences() -> void:
	var cases: Array[Dictionary] = [
		{"a": 1, "b": 1, "a_first": "AB", "b_first": "BA"},
		{"a": 4, "b": 4, "a_first": "ABABABAB", "b_first": "BABABABA"},
		{"a": 12, "b": 4, "a_first": "AABAAABAAABAAABA", "b_first": "ABAAABAAABAAABAA"},
		{"a": 7, "b": 4, "a_first": "ABAABABAABA", "b_first": "ABAABABAABA"},
		{"a": 5, "b": 3, "a_first": "ABAABABA", "b_first": "ABABAABA"},
		{"a": 12, "b": 7, "a_first": "ABAABABAABAABABAABA", "b_first": "ABAABABAABAABABAABA"},
		{"a": 1, "b": 8, "a_first": "BBBBABBBB", "b_first": "BBBBABBBB"},
		{"a": 0, "b": 5, "a_first": "BBBBB", "b_first": "BBBBB"},
		{"a": 5, "b": 0, "a_first": "AAAAA", "b_first": "AAAAA"},
	]
	for test_case in cases:
		for priority in [&"A", &"B"]:
			var expected: String = test_case["a_first"] if priority == &"A" else test_case["b_first"]
			var outcome: Dictionary = _simulate(int(test_case["a"]), int(test_case["b"]), priority)
			_expect_equal(outcome["sequence"], expected,
				"SWRR sequence %d:%d priority %s" % [test_case["a"], test_case["b"], priority])
			_expect_equal(outcome["sequence"].length(), int(test_case["a"]) + int(test_case["b"]),
				"calendar length must equal initial eligible roster")
			_expect_equal(outcome["count_a"], int(test_case["a"]), "calendar must consume exact A permissions")
			_expect_equal(outcome["count_b"], int(test_case["b"]), "calendar must consume exact B permissions")
			_expect(bool(outcome["finished"]), "calendar simulation must terminate after all pending permits")
			var metrics: Dictionary = outcome["metrics"]
			_expect_equal(metrics["count_a"], outcome["sequence"].count("A"),
				"derived metric A count must match sequence")
			_expect_equal(metrics["count_b"], outcome["sequence"].count("B"),
				"derived metric B count must match sequence")
			_expect(int(metrics["max_block"]) <= outcome["sequence"].length(),
				"derived maximum block must be bounded by the generated calendar")
			_expect(int(metrics["wait_between_a"]) >= 0 and int(metrics["wait_between_b"]) >= 0,
				"derived inter-activation waits must be nonnegative")
			_expect(float(metrics["max_deviation"]) >= 0.0,
				"derived proportional deviation must be nonnegative")
			print("R3-SWRR %d:%d priority=%s seq=%s metrics=%s" % [
				int(test_case["a"]), int(test_case["b"]), priority, outcome["sequence"], metrics,
			])

func _test_query_is_repeatable_and_non_mutating() -> void:
	var state := _make_state(7, 4, &"A")
	var scheduler := SchedulerScript.new()
	var before: Dictionary = state.scheduler_snapshot()
	var first: ActivationSchedulerResult = scheduler.peek(before)
	for _query in 5:
		var repeated: ActivationSchedulerResult = scheduler.peek(state.scheduler_snapshot())
		_expect_equal(repeated.permission_id, first.permission_id, "repeated peek must return same permission")
		_expect_equal(repeated.acting_side, first.acting_side, "repeated peek must preserve same side")
	_expect_equal(state.scheduler_snapshot(), before, "peek must not mutate battle state")
	_expect(first.permission_id.begins_with("1:0:"), "first permission must identify round and revision")

func _test_exact_reference_metrics() -> void:
	var cases: Array[Dictionary] = [
		{"a": 7, "b": 4, "sequence": "ABAABABAABA", "block": 2, "dmax": 5.0 / 11.0,
			"initial_a": 0, "initial_b": 1, "between_a": 1, "between_b": 2},
		{"a": 12, "b": 4, "sequence": "AABAAABAAABAAABA", "block": 3, "dmax": 0.5,
			"initial_a": 0, "initial_b": 2, "between_a": 1, "between_b": 3},
		{"a": 1, "b": 8, "sequence": "BBBBABBBB", "block": 4, "dmax": 4.0 / 9.0,
			"initial_a": 4, "initial_b": 0, "between_a": 0, "between_b": 1},
	]
	for test_case in cases:
		var outcome: Dictionary = _simulate(int(test_case["a"]), int(test_case["b"]), &"A")
		var metrics: Dictionary = outcome["metrics"]
		_expect_equal(outcome["sequence"], test_case["sequence"], "metric fixture calendar must match SWRR")
		_expect_equal(metrics["max_block"], test_case["block"], "derived max block must match exact reference")
		_expect(absf(float(metrics["max_deviation"]) - float(test_case["dmax"])) < 0.000001,
			"derived Dmax must match exact reference within 1e-6")
		_expect_equal(metrics["wait_initial_a"], test_case["initial_a"], "derived A initial wait must match")
		_expect_equal(metrics["wait_initial_b"], test_case["initial_b"], "derived B initial wait must match")
		_expect_equal(metrics["wait_between_a"], test_case["between_a"], "derived A inter-permission wait must match")
		_expect_equal(metrics["wait_between_b"], test_case["between_b"], "derived B inter-permission wait must match")

func _test_snapshot_is_detached() -> void:
	var state := _make_state(2, 1, &"A")
	var original: Dictionary = state.scheduler_snapshot()
	var escaped_weights: Dictionary = original["initial_weights"]
	escaped_weights[&"A"] = 0
	var escaped_credits: Dictionary = original["credits"]
	escaped_credits[&"A"] = 999
	var fresh: Dictionary = state.scheduler_snapshot()
	_expect_equal(fresh["initial_weights"][&"A"], 2, "snapshot weights must not expose authoritative storage")
	_expect_equal(fresh["credits"][&"A"], 0, "snapshot credits must not expose authoritative storage")

func _test_empty_round_and_invalid_snapshot() -> void:
	var scheduler := SchedulerScript.new()
	var empty_state := _make_state(0, 0, &"A")
	var complete: ActivationSchedulerResult = scheduler.peek(empty_state.scheduler_snapshot())
	_expect_equal(complete.status, ResultScript.Status.ROUND_COMPLETE,
		"zero-versus-zero must report round complete without a ghost permission")
	_expect_equal(complete.permission_id, "", "completed round must not expose a permission ID")
	var invalid: ActivationSchedulerResult = scheduler.peek({"round_id": -1})
	_expect_equal(invalid.status, ResultScript.Status.INVALID_STATE, "malformed scheduler snapshot must fail explicitly")
	_expect_equal(invalid.error_code, &"malformed_snapshot", "malformed snapshot must return typed error code")
	var inconsistent: Dictionary = _make_state(1, 1, &"A").scheduler_snapshot()
	inconsistent["pending_counts"][&"A"] = 2
	_expect_equal(scheduler.peek(inconsistent).status, ResultScript.Status.INVALID_STATE,
		"pending count above frozen roster weight must fail closed")
	var extreme: Dictionary = _make_state(1, 1, &"A").scheduler_snapshot()
	extreme["credits"][&"A"] = 9223372036854775807
	_expect_equal(scheduler.peek(extreme).status, ResultScript.Status.INVALID_STATE,
		"extreme credit must fail validation before arithmetic")
	var invalid_postcondition: Dictionary = _make_state(1, 1, &"A").scheduler_snapshot()
	invalid_postcondition["credits"][&"A"] = -200000
	invalid_postcondition["credits"][&"B"] = -200000
	var postcondition_result: ActivationSchedulerResult = scheduler.peek(invalid_postcondition)
	_expect_equal(postcondition_result.status, ResultScript.Status.INVALID_STATE,
		"SWRR must reject a permission whose proposed credits fail next-snapshot validation")
	_expect_equal(postcondition_result.error_code, &"invalid_resulting_credits",
		"out-of-range proposed credits must return an explicit typed error")
	_expect_equal(invalid_postcondition["credits"][&"A"], -200000,
		"rejected permission calculation must leave caller snapshot credits unchanged")

func _test_roster_validation() -> void:
	var state := BattleStateScript.new()
	var duplicate_ids: Array[String] = ["same", "same"]
	var duplicate_sides: Array[StringName] = [&"A", &"B"]
	_expect(not state.configure_round(duplicate_ids, duplicate_sides, &"A", &"B", &"A", 1),
		"duplicate unit IDs must reject roster initialization")
	_expect(not state.is_valid(), "rejected roster must not remain partially initialized")
	var mismatch_ids: Array[String] = ["only-one"]
	_expect(not state.configure_round(mismatch_ids, [], &"A", &"B", &"A", 1),
		"mismatched roster arrays must reject initialization")
	var invalid_side_ids: Array[String] = ["unit"]
	var invalid_sides: Array[StringName] = [&"C"]
	_expect(not state.configure_round(invalid_side_ids, invalid_sides, &"A", &"B", &"A", 1),
		"unit on an unregistered side must reject initialization")
	var valid_empty_ids: Array[String] = []
	var valid_empty_sides: Array[StringName] = []
	_expect(state.configure_round(valid_empty_ids, valid_empty_sides, &"A", &"B", &"A", 1),
		"zero-versus-zero roster is valid and immediately complete")

func _test_roster_reconfiguration_is_rejected() -> void:
	var state := _make_state(2, 1, &"A")
	var before_snapshot: Dictionary = state.scheduler_snapshot()
	var before_revision: int = state.revision()
	var before_permission: ActivationSchedulerResult = SchedulerScript.new().peek(before_snapshot)
	var invalid_ids: Array[String] = ["duplicate", "duplicate"]
	var invalid_sides: Array[StringName] = [&"A", &"B"]
	_expect(not state.configure_round(invalid_ids, invalid_sides, &"A", &"B", &"A", 2),
		"valid state must reject an invalid reconfiguration")
	_assert_state_unchanged(state, before_snapshot, before_revision, before_permission.permission_id,
		"invalid reconfiguration")
	var replacement_ids: Array[String] = ["replacement"]
	var replacement_sides: Array[StringName] = [&"B"]
	_expect(not state.configure_round(replacement_ids, replacement_sides, &"A", &"B", &"A", 1),
		"valid state must reject a second valid configuration with the same round ID")
	_assert_state_unchanged(state, before_snapshot, before_revision, before_permission.permission_id,
		"same-round reconfiguration")
	var fresh_state := BattleStateScript.new()
	_expect(fresh_state.configure_round(replacement_ids, replacement_sides, &"A", &"B", &"A", 1),
		"a fresh BattleState instance must accept a valid initial configuration")

func _assert_state_unchanged(state: BattleState, expected_snapshot: Dictionary,
		expected_revision: int, expected_permission_id: String, label: String) -> void:
	var actual_snapshot: Dictionary = state.scheduler_snapshot()
	_expect_equal(actual_snapshot, expected_snapshot, "%s must preserve snapshot and credits" % label)
	_expect_equal(state.revision(), expected_revision, "%s must preserve revision" % label)
	var permission: ActivationSchedulerResult = SchedulerScript.new().peek(actual_snapshot)
	_expect_equal(permission.permission_id, expected_permission_id,
		"%s must preserve the logical permission" % label)

func _simulate(count_a: int, count_b: int, priority: StringName) -> Dictionary:
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
		_failures.append("fixture BattleState failed to configure: %s" % state.error_code())
		return {"sequence": "", "count_a": 0, "count_b": 0, "finished": false}
	var snapshot: Dictionary = state.scheduler_snapshot()
	var scheduler := SchedulerScript.new()
	var sequence: String = ""
	var guard: int = count_a + count_b + 1
	while guard > 0:
		guard -= 1
		var permission: ActivationSchedulerResult = scheduler.peek(snapshot)
		if permission.status == ResultScript.Status.ROUND_COMPLETE:
			break
		if permission.status != ResultScript.Status.PERMISSION_AVAILABLE:
			_failures.append("scheduler rejected valid simulation snapshot: %s" % permission.error_code)
			break
		var winner: StringName = permission.acting_side
		sequence += String(winner)
		snapshot["pending_counts"][winner] = int(snapshot["pending_counts"][winner]) - 1
		snapshot["credits"][&"A"] = permission.next_credit_a
		snapshot["credits"][&"B"] = permission.next_credit_b
		snapshot["revision"] = int(snapshot["revision"]) + 1
	var final_result: ActivationSchedulerResult = scheduler.peek(snapshot)
	var count_final_a: int = sequence.count("A")
	var count_final_b: int = sequence.count("B")
	var metrics: Dictionary = _measure(sequence, count_a, count_b)
	return {
		"sequence": sequence,
		"count_a": count_final_a,
		"count_b": count_final_b,
		"finished": guard >= 0 and final_result.status == ResultScript.Status.ROUND_COMPLETE \
			and count_final_a == count_a and count_final_b == count_b,
		"metrics": metrics,
	}

func _measure(sequence: String, total_a: int, total_b: int) -> Dictionary:
	var count_a: int = 0
	var max_deviation: float = 0.0
	var max_block: int = 0
	var current_block: int = 0
	var previous: String = ""
	var positions_a: Array[int] = []
	var positions_b: Array[int] = []
	for index in sequence.length():
		var side: String = sequence.substr(index, 1)
		if side == "A":
			count_a += 1
			positions_a.append(index)
		else:
			positions_b.append(index)
		max_deviation = maxf(max_deviation,
			absf(float(count_a) - float(index + 1) * total_a / float(total_a + total_b)))
		if side == previous:
			current_block += 1
		else:
			previous = side
			current_block = 1
		max_block = maxi(max_block, current_block)
	return {
		"count_a": sequence.count("A"),
		"count_b": sequence.count("B"),
		"max_deviation": max_deviation,
		"max_block": max_block,
		"wait_initial_a": positions_a[0] if not positions_a.is_empty() else sequence.length(),
		"wait_initial_b": positions_b[0] if not positions_b.is_empty() else sequence.length(),
		"wait_between_a": _max_between(positions_a),
		"wait_between_b": _max_between(positions_b),
	}

func _max_between(positions: Array[int]) -> int:
	var maximum: int = 0
	for index in range(1, positions.size()):
		maximum = maxi(maximum, positions[index] - positions[index - 1] - 1)
	return maximum

func _make_state(count_a: int, count_b: int, priority: StringName) -> BattleState:
	var ids: Array[String] = []
	var sides: Array[StringName] = []
	for index in count_a:
		ids.append("fixture-a-%d" % index)
		sides.append(&"A")
	for index in count_b:
		ids.append("fixture-b-%d" % index)
		sides.append(&"B")
	var state := BattleStateScript.new()
	if not state.configure_round(ids, sides, &"A", &"B", priority, 1):
		_failures.append("BattleState fixture failed to configure: %s" % state.error_code())
	return state

func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)

func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [message, expected, actual])
