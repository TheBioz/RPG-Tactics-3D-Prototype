class_name ActivationCommandService
extends RefCounted
## Application boundary for consuming permissions, recording logical casualties,
## and explicitly starting the next ordinary-activation round.

const SchedulerScript = preload("res://scripts/r3/activation_scheduler.gd")
const ResultScript = preload("res://scripts/r3/activation_command_result.gd")

var _scheduler: ActivationScheduler = SchedulerScript.new()

func consume_ordinary_activation(state: BattleState, unit_id: String,
		permission_id: String, round_id: int) -> ActivationCommandResult:
	if state == null or not state.is_valid():
		return _result(ResultScript.Status.INVALID_STATE, &"invalid_battle_state")
	if round_id != state.round_id():
		return _state_result(state, ResultScript.Status.STALE_PERMISSION, &"round_mismatch")
	if permission_id.is_empty():
		return _state_result(state, ResultScript.Status.INVALID_PERMISSION, &"empty_permission_id")
	var permission: ActivationSchedulerResult = _scheduler.peek(state.scheduler_snapshot())
	if permission.status == ActivationSchedulerResult.Status.ROUND_COMPLETE:
		return _state_result(state, ResultScript.Status.ROUND_COMPLETE, &"no_pending_activations")
	if permission.status != ActivationSchedulerResult.Status.PERMISSION_AVAILABLE:
		return _state_result(state, ResultScript.Status.INVALID_STATE, permission.error_code)
	if permission.round_id != round_id or permission.state_revision != state.revision():
		return _state_result(state, ResultScript.Status.STALE_PERMISSION, &"permission_revision_mismatch")
	if permission.permission_id != permission_id:
		return _state_result(state, ResultScript.Status.STALE_PERMISSION, &"permission_not_current")
	if not state.contains_unit(unit_id):
		return _state_result(state, ResultScript.Status.UNKNOWN_UNIT, &"unknown_unit")
	if not state.unit_is_alive(unit_id):
		return _state_result(state, ResultScript.Status.UNIT_DEAD, &"unit_dead")
	if not state.unit_is_in_current_roster(unit_id):
		return _state_result(state, ResultScript.Status.UNIT_NOT_IN_ROSTER, &"unit_not_in_roster")
	if not state.unit_has_pending_activation(unit_id):
		return _state_result(state, ResultScript.Status.ACTIVATION_ALREADY_USED, &"activation_already_used")
	if state.unit_side_for(unit_id) != permission.acting_side:
		return _state_result(state, ResultScript.Status.WRONG_SIDE, &"unit_side_not_authorized")
	return state._commit_ordinary_activation(unit_id, permission)

func record_casualty(state: BattleState, unit_id: String, round_id: int,
		expected_revision: int) -> ActivationCommandResult:
	if state == null or not state.is_valid():
		return _result(ResultScript.Status.INVALID_STATE, &"invalid_battle_state")
	if round_id != state.round_id() or expected_revision != state.revision():
		return _state_result(state, ResultScript.Status.STALE_STATE, &"casualty_state_mismatch")
	if not state.contains_unit(unit_id):
		return _state_result(state, ResultScript.Status.UNKNOWN_UNIT, &"unknown_unit")
	if not state.unit_is_alive(unit_id):
		return _state_result(state, ResultScript.Status.UNIT_ALREADY_DEAD, &"unit_already_dead")
	if not state.unit_is_in_current_roster(unit_id):
		return _state_result(state, ResultScript.Status.UNIT_NOT_IN_ROSTER, &"unit_not_in_roster")
	return state._commit_casualty(unit_id, round_id, expected_revision)

func begin_next_round(state: BattleState, completed_round_id: int,
		expected_revision: int) -> ActivationCommandResult:
	if state == null or not state.is_valid():
		return _result(ResultScript.Status.INVALID_STATE, &"invalid_battle_state")
	if completed_round_id != state.round_id() or expected_revision != state.revision():
		return _state_result(state, ResultScript.Status.STALE_STATE, &"round_state_mismatch")
	var next_permission: ActivationSchedulerResult = _scheduler.peek(state.scheduler_snapshot())
	if next_permission.status == ActivationSchedulerResult.Status.INVALID_STATE:
		return _state_result(state, ResultScript.Status.INVALID_STATE, next_permission.error_code)
	if next_permission.status != ActivationSchedulerResult.Status.ROUND_COMPLETE:
		return _state_result(state, ResultScript.Status.ROUND_NOT_COMPLETE, &"ordinary_activations_pending")
	return state._commit_next_round(completed_round_id, expected_revision)

func _state_result(state: BattleState, status: ResultScript.Status,
		error_code: StringName) -> ActivationCommandResult:
	return ResultScript.new(status, error_code, state.round_id(), state.revision())

func _result(status: ResultScript.Status, error_code: StringName) -> ActivationCommandResult:
	return ResultScript.new(status, error_code)
