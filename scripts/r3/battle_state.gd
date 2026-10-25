class_name BattleState
extends RefCounted
## Authoritative, presentation-independent roster and ordinary-round ledger.

const MAX_UNITS_PER_SIDE: int = 100000
const MAX_COUNTER: int = 9223372036854775807
const CHECKPOINT_VERSION: int = 2
const SchedulerScript = preload("res://scripts/r3/activation_scheduler.gd")
const SchedulerResultScript = preload("res://scripts/r3/activation_scheduler_result.gd")
const TransitionResultScript = preload("res://scripts/r3/battle_transition_result.gd")

var _is_valid: bool = false
var _error_code: StringName = &"not_initialized"
var _round_id: int = 0
var _revision: int = 0
var _round_start_revision: int = 0
var _side_a: StringName = &""
var _side_b: StringName = &""
var _priority_side: StringName = &""
var _unit_ids: Array[String] = []
var _unit_sides: Array[StringName] = []
var _unit_alive: Array[bool] = []
var _unit_in_current_roster: Array[bool] = []
var _ordinary_activation_used: Array[bool] = []
var _unit_index_by_id: Dictionary = {}
var _initial_weights: Dictionary = {}
var _credits: Dictionary = {}

func configure_round(
		unit_ids: Array[String],
		unit_sides: Array[StringName],
		side_a: StringName,
		side_b: StringName,
		priority_side: StringName,
		round_id: int) -> bool:
	if _is_valid:
		return false
	_reset()
	if round_id <= 0 or side_a.is_empty() or side_b.is_empty() or side_a == side_b:
		_error_code = &"invalid_round_or_sides"
		return false
	if priority_side != side_a and priority_side != side_b:
		_error_code = &"invalid_priority_side"
		return false
	if unit_ids.size() != unit_sides.size() or unit_ids.size() > MAX_UNITS_PER_SIDE * 2:
		_error_code = &"invalid_roster_size"
		return false

	var weights: Dictionary = {side_a: 0, side_b: 0}
	var indices: Dictionary = {}
	for index in unit_ids.size():
		var unit_id: String = unit_ids[index]
		var unit_side: StringName = unit_sides[index]
		if unit_id.is_empty() or indices.has(unit_id):
			_error_code = &"invalid_or_duplicate_unit_id"
			return false
		if unit_side != side_a and unit_side != side_b:
			_error_code = &"invalid_unit_side"
			return false
		indices[unit_id] = index
		weights[unit_side] = int(weights[unit_side]) + 1
		if int(weights[unit_side]) > MAX_UNITS_PER_SIDE:
			_error_code = &"side_roster_limit_exceeded"
			return false

	_is_valid = true
	_error_code = &""
	_round_id = round_id
	_revision = 0
	_round_start_revision = 0
	_side_a = side_a
	_side_b = side_b
	_priority_side = priority_side
	_unit_ids = unit_ids.duplicate()
	_unit_sides = unit_sides.duplicate()
	_unit_alive.resize(unit_ids.size())
	_unit_alive.fill(true)
	_unit_in_current_roster.resize(unit_ids.size())
	_unit_in_current_roster.fill(true)
	_ordinary_activation_used.resize(unit_ids.size())
	_ordinary_activation_used.fill(false)
	_unit_index_by_id = indices
	_initial_weights = weights
	_credits = {side_a: 0, side_b: 0}
	return true

func is_valid() -> bool:
	return _is_valid

func error_code() -> StringName:
	return _error_code

func round_id() -> int:
	return _round_id

func revision() -> int:
	return _revision

func priority_side() -> StringName:
	return _priority_side

func unit_count() -> int:
	return _unit_ids.size()

func contains_unit(unit_id: String) -> bool:
	return _unit_index_by_id.has(unit_id)

func unit_side_for(unit_id: String) -> StringName:
	if not contains_unit(unit_id):
		return &""
	return _unit_sides[int(_unit_index_by_id[unit_id])]

func unit_is_alive(unit_id: String) -> bool:
	if not contains_unit(unit_id):
		return false
	return _unit_alive[int(_unit_index_by_id[unit_id])]

func unit_is_in_current_roster(unit_id: String) -> bool:
	if not contains_unit(unit_id):
		return false
	return _unit_in_current_roster[int(_unit_index_by_id[unit_id])]

func unit_has_ordinary_activation_used(unit_id: String) -> bool:
	if not contains_unit(unit_id):
		return false
	return _ordinary_activation_used[int(_unit_index_by_id[unit_id])]

func unit_has_pending_activation(unit_id: String) -> bool:
	return unit_is_alive(unit_id) and unit_is_in_current_roster(unit_id) \
		and not unit_has_ordinary_activation_used(unit_id)

func eligible_unit_ids_for_side(side: StringName) -> Array[String]:
	var eligible: Array[String] = []
	if not _is_valid or (side != _side_a and side != _side_b):
		return eligible
	for index in _unit_ids.size():
		if _unit_sides[index] == side and _unit_alive[index] \
			and _unit_in_current_roster[index] and not _ordinary_activation_used[index]:
			eligible.append(_unit_ids[index])
	return eligible

func scheduler_snapshot() -> Dictionary:
	if not _is_valid:
		return {}
	var pending: Dictionary = {_side_a: 0, _side_b: 0}
	for index in _unit_ids.size():
		if _unit_alive[index] and _unit_in_current_roster[index] \
			and not _ordinary_activation_used[index]:
			pending[_unit_sides[index]] = int(pending[_unit_sides[index]]) + 1
	return {
		"round_id": _round_id,
		"revision": _revision,
		"side_a": _side_a,
		"side_b": _side_b,
		"priority_side": _priority_side,
		"initial_weights": _initial_weights.duplicate(true),
		"pending_counts": pending.duplicate(true),
		"credits": _credits.duplicate(true),
	}

func to_checkpoint() -> Dictionary:
	if not _is_valid:
		return {}
	var unit_sides: Array[String] = []
	for side in _unit_sides:
		unit_sides.append(String(side))
	return {
		"format_version": CHECKPOINT_VERSION,
		"round_id": _round_id,
		"revision": _revision,
		"round_start_revision": _round_start_revision,
		"side_a": String(_side_a),
		"side_b": String(_side_b),
		"priority_side": String(_priority_side),
		"unit_ids": _unit_ids.duplicate(),
		"unit_sides": unit_sides,
		"unit_alive": _unit_alive.duplicate(),
		"unit_in_current_roster": _unit_in_current_roster.duplicate(),
		"ordinary_activation_used": _ordinary_activation_used.duplicate(),
		"initial_weights": {String(_side_a): int(_initial_weights[_side_a]),
			String(_side_b): int(_initial_weights[_side_b])},
		"credits": {String(_side_a): int(_credits[_side_a]),
			String(_side_b): int(_credits[_side_b])},
	}

static func restore_checkpoint(checkpoint: Variant) -> BattleState:
	var restored := BattleState.new()
	if typeof(checkpoint) != TYPE_DICTIONARY:
		restored._error_code = &"invalid_checkpoint"
		return restored
	var parsed: Dictionary = _parse_checkpoint(checkpoint)
	if not bool(parsed.get("valid", false)):
		restored._error_code = &"invalid_checkpoint"
		return restored

	var side_a: StringName = parsed["side_a"]
	var side_b: StringName = parsed["side_b"]
	var candidate_snapshot: Dictionary = {
		"round_id": parsed["round_id"],
		"revision": parsed["revision"],
		"side_a": side_a,
		"side_b": side_b,
		"priority_side": parsed["priority_side"],
		"initial_weights": parsed["initial_weights"],
		"pending_counts": parsed["pending_counts"],
		"credits": parsed["credits"],
	}
	var scheduler := SchedulerScript.new()
	var scheduler_result: ActivationSchedulerResult = scheduler.peek(candidate_snapshot)
	if scheduler_result.status == SchedulerResultScript.Status.INVALID_STATE:
		restored._error_code = &"invalid_checkpoint"
		return restored

	# Install only after the complete checkpoint and its scheduler state validate.
	restored._is_valid = true
	restored._error_code = &""
	restored._round_id = int(parsed["round_id"])
	restored._revision = int(parsed["revision"])
	restored._round_start_revision = int(parsed["round_start_revision"])
	restored._side_a = side_a
	restored._side_b = side_b
	restored._priority_side = parsed["priority_side"]
	restored._unit_ids = parsed["unit_ids"]
	restored._unit_sides = parsed["unit_sides"]
	restored._unit_alive = parsed["unit_alive"]
	restored._unit_in_current_roster = parsed["unit_in_current_roster"]
	restored._ordinary_activation_used = parsed["ordinary_activation_used"]
	restored._unit_index_by_id = parsed["unit_index_by_id"]
	restored._initial_weights = parsed["initial_weights"]
	restored._credits = parsed["credits"]
	return restored

func _commit_ordinary_activation(unit_id: String,
		permission: ActivationSchedulerResult) -> BattleTransitionResult:
	if not _is_valid or permission == null:
		return _transition_result(TransitionResultScript.Status.INVALID_STATE, &"invalid_battle_state")
	if permission.round_id != _round_id or permission.state_revision != _revision:
		return _transition_result(TransitionResultScript.Status.STALE_PERMISSION, &"permission_state_mismatch")
	var expected: ActivationSchedulerResult = SchedulerScript.new().peek(scheduler_snapshot())
	if expected.status != SchedulerResultScript.Status.PERMISSION_AVAILABLE \
		or expected.permission_id != permission.permission_id \
		or expected.acting_side != permission.acting_side \
		or expected.next_credit_a != permission.next_credit_a \
		or expected.next_credit_b != permission.next_credit_b:
		return _transition_result(TransitionResultScript.Status.STALE_PERMISSION, &"permission_revalidation_failed")
	if not contains_unit(unit_id):
		return _transition_result(TransitionResultScript.Status.UNKNOWN_UNIT, &"unknown_unit")
	var unit_index: int = int(_unit_index_by_id[unit_id])
	if not _unit_alive[unit_index]:
		return _transition_result(TransitionResultScript.Status.UNIT_DEAD, &"unit_dead")
	if not _unit_in_current_roster[unit_index]:
		return _transition_result(TransitionResultScript.Status.UNIT_NOT_IN_ROSTER, &"unit_not_in_roster")
	if _ordinary_activation_used[unit_index]:
		return _transition_result(TransitionResultScript.Status.ACTIVATION_ALREADY_USED, &"activation_already_used")
	if _unit_sides[unit_index] != expected.acting_side:
		return _transition_result(TransitionResultScript.Status.WRONG_SIDE, &"unit_side_not_authorized")
	if _revision == MAX_COUNTER:
		return _transition_result(TransitionResultScript.Status.REVISION_EXHAUSTED, &"revision_exhausted")

	# No validation remains after this point: commit ledger, credits, and revision together.
	_ordinary_activation_used[unit_index] = true
	_credits[_side_a] = expected.next_credit_a
	_credits[_side_b] = expected.next_credit_b
	_revision += 1
	return _transition_result(TransitionResultScript.Status.APPLIED, &"")

func _commit_casualty(unit_id: String, expected_round_id: int,
		expected_revision: int) -> BattleTransitionResult:
	if not _is_valid:
		return _transition_result(TransitionResultScript.Status.INVALID_STATE, &"invalid_battle_state")
	if expected_round_id != _round_id or expected_revision != _revision:
		return _transition_result(TransitionResultScript.Status.STALE_STATE, &"casualty_state_mismatch")
	if not contains_unit(unit_id):
		return _transition_result(TransitionResultScript.Status.UNKNOWN_UNIT, &"unknown_unit")
	var unit_index: int = int(_unit_index_by_id[unit_id])
	if not _unit_alive[unit_index]:
		return _transition_result(TransitionResultScript.Status.UNIT_ALREADY_DEAD, &"unit_already_dead")
	if not _unit_in_current_roster[unit_index]:
		return _transition_result(TransitionResultScript.Status.UNIT_NOT_IN_ROSTER, &"unit_not_in_roster")
	if _revision == MAX_COUNTER:
		return _transition_result(TransitionResultScript.Status.REVISION_EXHAUSTED, &"revision_exhausted")
	_unit_alive[unit_index] = false
	_revision += 1
	return _transition_result(TransitionResultScript.Status.APPLIED, &"")

func _commit_next_round(expected_round_id: int,
		expected_revision: int) -> BattleTransitionResult:
	if not _is_valid:
		return _transition_result(TransitionResultScript.Status.INVALID_STATE, &"invalid_battle_state")
	if expected_round_id != _round_id or expected_revision != _revision:
		return _transition_result(TransitionResultScript.Status.STALE_STATE, &"round_state_mismatch")
	var expected: ActivationSchedulerResult = SchedulerScript.new().peek(scheduler_snapshot())
	if expected.status != SchedulerResultScript.Status.ROUND_COMPLETE:
		return _transition_result(TransitionResultScript.Status.ROUND_NOT_COMPLETE, &"ordinary_activations_pending")
	if _revision == MAX_COUNTER:
		return _transition_result(TransitionResultScript.Status.REVISION_EXHAUSTED, &"revision_exhausted")
	if _round_id == MAX_COUNTER:
		return _transition_result(TransitionResultScript.Status.ROUND_ID_EXHAUSTED, &"round_id_exhausted")

	var next_weights: Dictionary = {_side_a: 0, _side_b: 0}
	var next_roster: Array[bool] = []
	var reset_activations: Array[bool] = []
	for index in _unit_ids.size():
		var participates: bool = _unit_alive[index]
		next_roster.append(participates)
		reset_activations.append(false)
		if participates:
			next_weights[_unit_sides[index]] = int(next_weights[_unit_sides[index]]) + 1

	# Apply a fully prepared next-round state in one synchronous mutation.
	_unit_in_current_roster = next_roster
	_ordinary_activation_used = reset_activations
	_initial_weights = next_weights
	_credits = {_side_a: 0, _side_b: 0}
	_priority_side = _side_b if _priority_side == _side_a else _side_a
	_round_id += 1
	_revision += 1
	_round_start_revision = _revision
	return _transition_result(TransitionResultScript.Status.APPLIED, &"")

func _transition_result(status: BattleTransitionResult.Status,
		error_code: StringName) -> BattleTransitionResult:
	return TransitionResultScript.new(status, error_code, _round_id, _revision)

static func _parse_checkpoint(checkpoint: Dictionary) -> Dictionary:
	var keys: Array[String] = ["format_version", "round_id", "revision", "round_start_revision", "side_a", "side_b",
		"priority_side", "unit_ids", "unit_sides", "unit_alive", "unit_in_current_roster",
		"ordinary_activation_used", "initial_weights", "credits"]
	for key in keys:
		if not checkpoint.has(key):
			return {"valid": false}
	if not _is_integer_between(checkpoint["format_version"], CHECKPOINT_VERSION, CHECKPOINT_VERSION) \
		or not _is_integer_between(checkpoint["round_id"], 1, MAX_COUNTER) \
		or not _is_integer_between(checkpoint["revision"], 0, MAX_COUNTER) \
		or not _is_integer_between(checkpoint["round_start_revision"], 0, MAX_COUNTER) \
		or int(checkpoint["round_start_revision"]) > int(checkpoint["revision"]):
		return {"valid": false}
	for key in ["side_a", "side_b", "priority_side"]:
		if typeof(checkpoint[key]) != TYPE_STRING or String(checkpoint[key]).is_empty():
			return {"valid": false}
	var side_a := StringName(checkpoint["side_a"])
	var side_b := StringName(checkpoint["side_b"])
	var priority := StringName(checkpoint["priority_side"])
	if side_a == side_b or (priority != side_a and priority != side_b):
		return {"valid": false}
	for key in ["unit_ids", "unit_sides", "unit_alive", "unit_in_current_roster", "ordinary_activation_used"]:
		if typeof(checkpoint[key]) != TYPE_ARRAY:
			return {"valid": false}
	var ids: Array = checkpoint["unit_ids"]
	var sides: Array = checkpoint["unit_sides"]
	var alive: Array = checkpoint["unit_alive"]
	var in_roster: Array = checkpoint["unit_in_current_roster"]
	var used: Array = checkpoint["ordinary_activation_used"]
	if ids.size() > MAX_UNITS_PER_SIDE * 2 or sides.size() != ids.size() \
		or alive.size() != ids.size() or in_roster.size() != ids.size() or used.size() != ids.size():
		return {"valid": false}
	var typed_ids: Array[String] = []
	var typed_sides: Array[StringName] = []
	var typed_alive: Array[bool] = []
	var typed_roster: Array[bool] = []
	var typed_used: Array[bool] = []
	var indices: Dictionary = {}
	var weights: Dictionary = {side_a: 0, side_b: 0}
	var represented_transitions: int = 0
	var all_roster_units_alive_and_pending: bool = true
	for index in ids.size():
		if typeof(ids[index]) != TYPE_STRING or typeof(sides[index]) != TYPE_STRING \
			or typeof(alive[index]) != TYPE_BOOL or typeof(in_roster[index]) != TYPE_BOOL \
			or typeof(used[index]) != TYPE_BOOL:
			return {"valid": false}
		var unit_id: String = ids[index]
		var unit_side := StringName(sides[index])
		if unit_id.is_empty() or indices.has(unit_id) or (unit_side != side_a and unit_side != side_b):
			return {"valid": false}
		var unit_alive: bool = alive[index]
		var unit_in_roster: bool = in_roster[index]
		var unit_used: bool = used[index]
		if (unit_alive and not unit_in_roster) or (unit_used and not unit_in_roster):
			return {"valid": false}
		if unit_used:
			represented_transitions += 1
		if unit_in_roster and not unit_alive:
			represented_transitions += 1
			all_roster_units_alive_and_pending = false
		elif unit_in_roster and unit_used:
			all_roster_units_alive_and_pending = false
		indices[unit_id] = index
		typed_ids.append(unit_id)
		typed_sides.append(unit_side)
		typed_alive.append(unit_alive)
		typed_roster.append(unit_in_roster)
		typed_used.append(unit_used)
		if unit_in_roster:
			weights[unit_side] = int(weights[unit_side]) + 1
			if int(weights[unit_side]) > MAX_UNITS_PER_SIDE:
				return {"valid": false}
	var weight_data: Dictionary = _parse_pair_of_ints(checkpoint["initial_weights"], side_a, side_b,
		0, MAX_UNITS_PER_SIDE)
	var credit_data: Dictionary = _parse_pair_of_ints(checkpoint["credits"], side_a, side_b,
		-MAX_UNITS_PER_SIDE * 2, MAX_UNITS_PER_SIDE * 2)
	if weight_data.is_empty() or credit_data.is_empty():
		return {"valid": false}
	if int(weight_data[side_a]) != int(weights[side_a]) \
		or int(weight_data[side_b]) != int(weights[side_b]):
		return {"valid": false}
	var revision: int = int(checkpoint["revision"])
	var round_start_revision: int = int(checkpoint["round_start_revision"])
	if revision - round_start_revision != represented_transitions:
		return {"valid": false}
	if int(credit_data[side_a]) + int(credit_data[side_b]) != 0:
		return {"valid": false}
	if all_roster_units_alive_and_pending \
		and (int(credit_data[side_a]) != 0 or int(credit_data[side_b]) != 0):
		return {"valid": false}
	if revision == 0:
		if round_start_revision != 0 or typed_ids.size() != int(weights[side_a]) + int(weights[side_b]):
			return {"valid": false}
		for index in typed_ids.size():
			if not typed_alive[index] or not typed_roster[index] or typed_used[index]:
				return {"valid": false}
	var pending: Dictionary = {side_a: 0, side_b: 0}
	for index in typed_ids.size():
		if typed_alive[index] and typed_roster[index] and not typed_used[index]:
			pending[typed_sides[index]] = int(pending[typed_sides[index]]) + 1
	return {
		"valid": true,
		"round_id": int(checkpoint["round_id"]),
		"revision": int(checkpoint["revision"]),
		"round_start_revision": round_start_revision,
		"side_a": side_a,
		"side_b": side_b,
		"priority_side": priority,
		"unit_ids": typed_ids,
		"unit_sides": typed_sides,
		"unit_alive": typed_alive,
		"unit_in_current_roster": typed_roster,
		"ordinary_activation_used": typed_used,
		"unit_index_by_id": indices,
		"initial_weights": weight_data,
		"credits": credit_data,
		"pending_counts": pending,
	}

static func _parse_pair_of_ints(data: Variant, side_a: StringName, side_b: StringName,
		minimum: int, maximum: int) -> Dictionary:
	if typeof(data) != TYPE_DICTIONARY:
		return {}
	var source: Dictionary = data
	var key_a: String = String(side_a)
	var key_b: String = String(side_b)
	if not source.has(key_a) or not source.has(key_b):
		return {}
	var value_a: Variant = source[key_a]
	var value_b: Variant = source[key_b]
	if typeof(value_a) != TYPE_INT or typeof(value_b) != TYPE_INT \
		or int(value_a) < minimum or int(value_a) > maximum \
		or int(value_b) < minimum or int(value_b) > maximum:
		return {}
	return {side_a: int(value_a), side_b: int(value_b)}

static func _is_integer_between(value: Variant, minimum: int, maximum: int) -> bool:
	return typeof(value) == TYPE_INT and int(value) >= minimum and int(value) <= maximum

func _reset() -> void:
	_is_valid = false
	_error_code = &"not_initialized"
	_round_id = 0
	_revision = 0
	_round_start_revision = 0
	_side_a = &""
	_side_b = &""
	_priority_side = &""
	_unit_ids.clear()
	_unit_sides.clear()
	_unit_alive.clear()
	_unit_in_current_roster.clear()
	_ordinary_activation_used.clear()
	_unit_index_by_id.clear()
	_initial_weights.clear()
	_credits.clear()
