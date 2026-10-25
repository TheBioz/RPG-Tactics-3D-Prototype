class_name ActivationCommandService
extends RefCounted
## Application boundary for consuming permissions, recording logical casualties,
## and explicitly starting the next ordinary-activation round.

const SchedulerScript = preload("res://scripts/r3/activation_scheduler.gd")
const ResultScript = preload("res://scripts/r3/activation_command_result.gd")
const TransitionResultScript = preload("res://scripts/r3/battle_transition_result.gd")

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
	return _map_domain_result(state._commit_ordinary_activation(unit_id, permission))

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
	return _map_domain_result(state._commit_casualty(unit_id, round_id, expected_revision))

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
	return _map_domain_result(state._commit_next_round(completed_round_id, expected_revision))

func _map_domain_result(domain_result: BattleTransitionResult) -> ActivationCommandResult:
	if domain_result == null:
		return _result(ResultScript.Status.INVALID_STATE, &"missing_domain_transition_result")
	var application_status: ResultScript.Status
	match domain_result.status:
		TransitionResultScript.Status.APPLIED:
			application_status = ResultScript.Status.APPLIED
		TransitionResultScript.Status.INVALID_STATE:
			application_status = ResultScript.Status.INVALID_STATE
		TransitionResultScript.Status.STALE_PERMISSION:
			application_status = ResultScript.Status.STALE_PERMISSION
		TransitionResultScript.Status.UNKNOWN_UNIT:
			application_status = ResultScript.Status.UNKNOWN_UNIT
		TransitionResultScript.Status.UNIT_DEAD:
			application_status = ResultScript.Status.UNIT_DEAD
		TransitionResultScript.Status.UNIT_NOT_IN_ROSTER:
			application_status = ResultScript.Status.UNIT_NOT_IN_ROSTER
		TransitionResultScript.Status.ACTIVATION_ALREADY_USED:
			application_status = ResultScript.Status.ACTIVATION_ALREADY_USED
		TransitionResultScript.Status.WRONG_SIDE:
			application_status = ResultScript.Status.WRONG_SIDE
		TransitionResultScript.Status.REVISION_EXHAUSTED:
			application_status = ResultScript.Status.REVISION_EXHAUSTED
		TransitionResultScript.Status.STALE_STATE:
			application_status = ResultScript.Status.STALE_STATE
		TransitionResultScript.Status.UNIT_ALREADY_DEAD:
			application_status = ResultScript.Status.UNIT_ALREADY_DEAD
		TransitionResultScript.Status.ROUND_NOT_COMPLETE:
			application_status = ResultScript.Status.ROUND_NOT_COMPLETE
		TransitionResultScript.Status.ROUND_ID_EXHAUSTED:
			application_status = ResultScript.Status.ROUND_ID_EXHAUSTED
		_:
			return ResultScript.new(ResultScript.Status.INVALID_STATE,
				&"unmapped_domain_transition_status", domain_result.round_id,
				domain_result.state_revision)
	return ResultScript.new(application_status, domain_result.error_code,
		domain_result.round_id, domain_result.state_revision)

func _state_result(state: BattleState, status: ResultScript.Status,
		error_code: StringName) -> ActivationCommandResult:
	return ResultScript.new(status, error_code, state.round_id(), state.revision())

func _result(status: ResultScript.Status, error_code: StringName) -> ActivationCommandResult:
	return ResultScript.new(status, error_code)
