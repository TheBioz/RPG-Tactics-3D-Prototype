class_name ActivationScheduler
extends RefCounted
## Pure integer SWRR calculation. It proposes a permission and next credits;
## callers must not treat a query as a committed activation.

const ResultScript = preload("res://scripts/r3/activation_scheduler_result.gd")
const MAX_UNITS_PER_SIDE: int = 100000

func peek(snapshot: Dictionary) -> ActivationSchedulerResult:
	var invalid := _invalid_result(&"malformed_snapshot")
	if not _has_valid_snapshot_shape(snapshot):
		return invalid

	var side_a: StringName = snapshot["side_a"]
	var side_b: StringName = snapshot["side_b"]
	var priority: StringName = snapshot["priority_side"]
	var weights: Dictionary = snapshot["initial_weights"]
	var pending: Dictionary = snapshot["pending_counts"]
	var credits: Dictionary = snapshot["credits"]
	var pending_a: int = int(pending[side_a])
	var pending_b: int = int(pending[side_b])
	var credit_a: int = int(credits[side_a])
	var credit_b: int = int(credits[side_b])
	if pending_a == 0 and pending_b == 0:
		return ResultScript.new(
			ActivationSchedulerResult.Status.ROUND_COMPLETE,
			&"", "", int(snapshot["round_id"]), int(snapshot["revision"]),
			credit_a, credit_b)

	var weight_a: int = int(weights[side_a]) if pending_a > 0 else 0
	var weight_b: int = int(weights[side_b]) if pending_b > 0 else 0
	var active_weight_sum: int = weight_a + weight_b
	if active_weight_sum <= 0 or active_weight_sum > MAX_UNITS_PER_SIDE * 2:
		return _invalid_result(&"invalid_active_weights")
	if credit_a > 9223372036854775807 - weight_a \
		or credit_b > 9223372036854775807 - weight_b:
		return _invalid_result(&"credit_overflow")

	var accumulated_a: int = credit_a + weight_a
	var accumulated_b: int = credit_b + weight_b
	var winner: StringName
	if pending_a == 0:
		winner = side_b
	elif pending_b == 0:
		winner = side_a
	elif accumulated_a > accumulated_b:
		winner = side_a
	elif accumulated_b > accumulated_a:
		winner = side_b
	else:
		winner = priority

	if winner == side_a:
		accumulated_a -= active_weight_sum
	else:
		accumulated_b -= active_weight_sum
	var round_number: int = int(snapshot["round_id"])
	var state_revision: int = int(snapshot["revision"])
	var permission_id: String = "%d:%d:%s" % [round_number, state_revision, String(winner)]
	return ResultScript.new(
		ActivationSchedulerResult.Status.PERMISSION_AVAILABLE,
		winner,
		permission_id,
		round_number,
		state_revision,
		accumulated_a,
		accumulated_b)

func _has_valid_snapshot_shape(snapshot: Dictionary) -> bool:
	for key in ["round_id", "revision", "side_a", "side_b", "priority_side",
			"initial_weights", "pending_counts", "credits"]:
		if not snapshot.has(key):
			return false
	if typeof(snapshot["round_id"]) != TYPE_INT or int(snapshot["round_id"]) <= 0:
		return false
	if typeof(snapshot["revision"]) != TYPE_INT or int(snapshot["revision"]) < 0:
		return false
	if typeof(snapshot["side_a"]) != TYPE_STRING_NAME \
		or typeof(snapshot["side_b"]) != TYPE_STRING_NAME \
		or typeof(snapshot["priority_side"]) != TYPE_STRING_NAME:
		return false
	var side_a: StringName = snapshot["side_a"]
	var side_b: StringName = snapshot["side_b"]
	if side_a.is_empty() or side_b.is_empty() or side_a == side_b:
		return false
	var priority: StringName = snapshot["priority_side"]
	if priority != side_a and priority != side_b:
		return false
	for field in ["initial_weights", "pending_counts", "credits"]:
		if typeof(snapshot[field]) != TYPE_DICTIONARY:
			return false
		var values: Dictionary = snapshot[field]
		if not values.has(side_a) or not values.has(side_b):
			return false
	if not _valid_nonnegative(snapshot["initial_weights"][side_a], MAX_UNITS_PER_SIDE) \
		or not _valid_nonnegative(snapshot["initial_weights"][side_b], MAX_UNITS_PER_SIDE):
		return false
	if not _valid_nonnegative(snapshot["pending_counts"][side_a], MAX_UNITS_PER_SIDE) \
		or not _valid_nonnegative(snapshot["pending_counts"][side_b], MAX_UNITS_PER_SIDE):
		return false
	if int(snapshot["pending_counts"][side_a]) > int(snapshot["initial_weights"][side_a]) \
		or int(snapshot["pending_counts"][side_b]) > int(snapshot["initial_weights"][side_b]):
		return false
	if typeof(snapshot["credits"][side_a]) != TYPE_INT \
		or typeof(snapshot["credits"][side_b]) != TYPE_INT:
		return false
	if int(snapshot["credits"][side_a]) < -MAX_UNITS_PER_SIDE * 2 \
		or int(snapshot["credits"][side_a]) > MAX_UNITS_PER_SIDE * 2 \
		or int(snapshot["credits"][side_b]) < -MAX_UNITS_PER_SIDE * 2 \
		or int(snapshot["credits"][side_b]) > MAX_UNITS_PER_SIDE * 2:
		return false
	return true

func _valid_nonnegative(value: Variant, maximum: int) -> bool:
	return typeof(value) == TYPE_INT and int(value) >= 0 and int(value) <= maximum

func _invalid_result(code: StringName) -> ActivationSchedulerResult:
	return ResultScript.new(ActivationSchedulerResult.Status.INVALID_STATE, &"", "", -1, -1, 0, 0, code)
