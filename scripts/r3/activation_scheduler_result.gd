class_name ActivationSchedulerResult
extends RefCounted
## Value result returned by the pure SWRR permission query.

enum Status {
	PERMISSION_AVAILABLE,
	ROUND_COMPLETE,
	INVALID_STATE,
}

var status: Status = Status.INVALID_STATE
var acting_side: StringName = &""
var permission_id: String = ""
var round_id: int = -1
var state_revision: int = -1
var next_credit_a: int = 0
var next_credit_b: int = 0
var error_code: StringName = &""

func _init(
		result_status: Status = Status.INVALID_STATE,
		result_side: StringName = &"",
		result_permission_id: String = "",
		result_round_id: int = -1,
		result_revision: int = -1,
		result_credit_a: int = 0,
		result_credit_b: int = 0,
		result_error: StringName = &"") -> void:
	status = result_status
	acting_side = result_side
	permission_id = result_permission_id
	round_id = result_round_id
	state_revision = result_revision
	next_credit_a = result_credit_a
	next_credit_b = result_credit_b
	error_code = result_error

func is_permission_available() -> bool:
	return status == Status.PERMISSION_AVAILABLE
