class_name BattleState
extends RefCounted
## Authoritative, presentation-independent roster and ordinary-round ledger.

const MAX_UNITS_PER_SIDE: int = 100000

var _is_valid: bool = false
var _error_code: StringName = &"not_initialized"
var _round_id: int = 0
var _revision: int = 0
var _side_a: StringName = &""
var _side_b: StringName = &""
var _priority_side: StringName = &""
var _unit_ids: Array[String] = []
var _unit_sides: Array[StringName] = []
var _unit_alive: Array[bool] = []
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
	_side_a = side_a
	_side_b = side_b
	_priority_side = priority_side
	_unit_ids = unit_ids.duplicate()
	_unit_sides = unit_sides.duplicate()
	_unit_alive.resize(unit_ids.size())
	_unit_alive.fill(true)
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

func scheduler_snapshot() -> Dictionary:
	if not _is_valid:
		return {}
	var pending: Dictionary = {_side_a: 0, _side_b: 0}
	for index in _unit_ids.size():
		if _unit_alive[index] and not _ordinary_activation_used[index]:
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

func _reset() -> void:
	_is_valid = false
	_error_code = &"not_initialized"
	_round_id = 0
	_revision = 0
	_side_a = &""
	_side_b = &""
	_priority_side = &""
	_unit_ids.clear()
	_unit_sides.clear()
	_unit_alive.clear()
	_ordinary_activation_used.clear()
	_unit_index_by_id.clear()
	_initial_weights.clear()
	_credits.clear()
