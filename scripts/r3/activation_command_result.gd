class_name ActivationCommandResult
extends RefCounted
## Typed result for authoritative ordinary-activation and round transitions.

enum Status {
	APPLIED,
	INVALID_STATE,
	ROUND_COMPLETE,
	INVALID_PERMISSION,
	STALE_PERMISSION,
	STALE_STATE,
	UNKNOWN_UNIT,
	UNIT_DEAD,
	UNIT_NOT_IN_ROSTER,
	WRONG_SIDE,
	ACTIVATION_ALREADY_USED,
	UNIT_ALREADY_DEAD,
	ROUND_NOT_COMPLETE,
	REVISION_EXHAUSTED,
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
