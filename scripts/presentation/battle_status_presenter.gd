class_name BattleStatusPresenter
extends RefCounted
## Read-only textual presentation of the real R3 turn state for the R3-D1 demo.

const SchedulerScript = preload("res://scripts/r3/activation_scheduler.gd")
const SchedulerResultScript = preload("res://scripts/r3/activation_scheduler_result.gd")

var _scheduler: ActivationScheduler = SchedulerScript.new()

func format_status(state: BattleState) -> String:
	if state == null or not state.is_valid():
		return "TURNOS DEMO — INVALID_STATE"

	var snapshot: Dictionary = state.scheduler_snapshot()
	var permission: ActivationSchedulerResult = _scheduler.peek(snapshot)
	if permission.status == SchedulerResultScript.Status.INVALID_STATE:
		return "TURNOS DEMO — INVALID_STATE (%s)" % permission.error_code

	var lines: PackedStringArray = ["TURNOS DEMO (BattleState real; roster sin asociación a sprites)"]
	lines.append("Ronda: %d" % state.round_id())
	if permission.status == SchedulerResultScript.Status.ROUND_COMPLETE:
		lines.append("Estado: ROUND_COMPLETE (no indica victoria/derrota)")
	else:
		lines.append("Bando con permiso: %s" % String(permission.acting_side))

	for side in [snapshot["side_a"], snapshot["side_b"]]:
		var pending: Array[String] = state.eligible_unit_ids_for_side(side)
		var acted: Array[String] = []
		var casualties: Array[String] = []
		for unit_id in state.unit_ids():
			if state.unit_side_for(unit_id) != side or not state.unit_is_in_current_roster(unit_id):
				continue
			if state.unit_has_ordinary_activation_used(unit_id):
				acted.append(unit_id)
			if not state.unit_is_alive(unit_id):
				casualties.append(unit_id)
		lines.append("%s elegibles: %s" % [String(side), _format_unit_ids(pending)])
		lines.append("%s actuaron: %s" % [String(side), _format_unit_ids(acted)])
		lines.append("%s bajas: %s" % [String(side), _format_unit_ids(casualties)])
	return "\n".join(lines)

func _format_unit_ids(unit_ids: Array[String]) -> String:
	return ", ".join(unit_ids) if not unit_ids.is_empty() else "—"
