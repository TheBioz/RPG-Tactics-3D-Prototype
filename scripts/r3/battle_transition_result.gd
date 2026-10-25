class_name BattleTransitionResult
extends RefCounted
## Domain-owned result for a validated BattleState transition.

enum Status {
	APPLIED,
	INVALID_STATE,
	STALE_PERMISSION,
	UNKNOWN_UNIT,
	UNIT_DEAD,
	UNIT_NOT_IN_ROSTER,
	ACTIVATION_ALREADY_USED,
	WRONG_SIDE,
	REVISION_EXHAUSTED,
	STALE_STATE,
	UNIT_ALREADY_DEAD,
	ROUND_NOT_COMPLETE,
	ROUND_ID_EXHAUSTED,
}

var status: Status = Status.INVALID_STATE
var error_code: StringName = &""
var round_id: int = -1
var state_revision: int = -1

func _init(result_status: Status, result_error: StringName = &"",
		result_round_id: int = -1, result_revision: int = -1) -> void:
	status = result_status
	error_code = result_error
	round_id = result_round_id
	state_revision = result_revision

func is_applied() -> bool:
	return status == Status.APPLIED
