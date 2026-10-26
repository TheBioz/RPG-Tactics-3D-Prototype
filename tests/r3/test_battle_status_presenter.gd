extends RefCounted
## Read-only BattleStatusPresenter tests using real R3 state/scheduler objects.

const BattleStateScript = preload("res://scripts/r3/battle_state.gd")
const SchedulerScript = preload("res://scripts/r3/activation_scheduler.gd")
const CommandServiceScript = preload("res://scripts/r3/activation_command_service.gd")
const PresenterScript = preload("res://scripts/presentation/battle_status_presenter.gd")
const SchedulerResultScript = preload("res://scripts/r3/activation_scheduler_result.gd")
const CommandResultScript = preload("res://scripts/r3/activation_command_result.gd")

var _checks: int = 0
var _failures: PackedStringArray = []
var _presenter: BattleStatusPresenter
var _scheduler: ActivationScheduler
var _service: ActivationCommandService

func run() -> Dictionary:
	_presenter = PresenterScript.new()
	_scheduler = SchedulerScript.new()
	_service = CommandServiceScript.new()
	_test_initial_rosters_and_permissions()
	_test_consumed_unit_and_side_change()
	_test_round_complete_empty_and_invalid()
	_test_queries_are_read_only_and_detached()
	_test_presenter_has_no_scene_dependencies()
	return {"checks": _checks, "failures": _failures}

func _test_initial_rosters_and_permissions() -> void:
	var state_1v1 := _make_state(1, 1, &"PLAYER")
	var text_1v1: String = _presenter.format_status(state_1v1)
	_expect(text_1v1.contains("Ronda: 1"), "presenter displays live BattleState round")
	_expect(text_1v1.contains("Bando con permiso: PLAYER"), "presenter displays SWRR-authorized side")
	_expect(text_1v1.contains("PLAYER elegibles: player_unit_01"), "presenter lists current eligible player unit")
	_expect(text_1v1.contains("ENEMY elegibles: enemy_unit_01"), "presenter lists current eligible enemy unit")
	_expect(text_1v1.contains("PLAYER actuaron: —"), "initially unused player roster is not marked acted")
	_expect(text_1v1.contains("sin asociación a sprites"), "demo clearly disclaims a roster-to-sprite mapping")

	var state_2v2 := _make_state(2, 2, &"PLAYER")
	var text_2v2: String = _presenter.format_status(state_2v2)
	_expect(text_2v2.contains("PLAYER elegibles: player_unit_01, player_unit_02"),
		"2:2 presenter lists both real player roster IDs")
	_expect(text_2v2.contains("ENEMY elegibles: enemy_unit_01, enemy_unit_02"),
		"2:2 presenter lists both real enemy roster IDs")
	var query: ActivationSchedulerResult = _scheduler.peek(state_2v2.scheduler_snapshot())
	_expect_equal(query.acting_side, &"PLAYER", "2:2 priority PLAYER permission comes from SWRR")
	_expect(text_2v2.contains("Bando con permiso: %s" % String(query.acting_side)),
		"presented permission matches scheduler result")

func _test_consumed_unit_and_side_change() -> void:
	var state := _make_state(2, 2, &"PLAYER")
	var player_permission: ActivationSchedulerResult = _scheduler.peek(state.scheduler_snapshot())
	var player_unit: String = state.eligible_unit_ids_for_side(player_permission.acting_side)[0]
	var player_result: ActivationCommandResult = _service.consume_ordinary_activation(
		state, player_unit, player_permission.permission_id, player_permission.round_id)
	_expect_equal(player_result.status, CommandResultScript.Status.APPLIED,
		"test fixture consumes a player activation through the authoritative service")
	var after_player := _presenter.format_status(state)
	_expect(after_player.contains("PLAYER actuaron: %s" % player_unit),
		"presenter reflects the actual consumed player activation")
	_expect(after_player.contains("PLAYER elegibles: player_unit_02"),
		"presenter reflects the remaining player-eligible roster")
	var enemy_permission: ActivationSchedulerResult = _scheduler.peek(state.scheduler_snapshot())
	_expect_equal(enemy_permission.acting_side, &"ENEMY", "next SWRR permission changes side in the 2:2 fixture")
	_expect(after_player.contains("Bando con permiso: %s" % String(enemy_permission.acting_side)),
		"presented side changes with the authoritative SWRR result")
	var enemy_unit: String = state.eligible_unit_ids_for_side(enemy_permission.acting_side)[0]
	_expect(_service.consume_ordinary_activation(state, enemy_unit,
		enemy_permission.permission_id, enemy_permission.round_id).is_applied(),
		"test fixture consumes enemy activation through the same service")
	var after_enemy := _presenter.format_status(state)
	_expect(after_enemy.contains("ENEMY actuaron: %s" % enemy_unit),
		"presenter reflects the actual consumed enemy activation")
	_expect_equal(_scheduler.peek(state.scheduler_snapshot()).acting_side, &"PLAYER",
		"presenter fixture follows real scheduler back to PLAYER")

	var casualty_state := _make_state(1, 1, &"PLAYER")
	var first_permission: ActivationSchedulerResult = _scheduler.peek(casualty_state.scheduler_snapshot())
	_expect(_service.consume_ordinary_activation(casualty_state, "player_unit_01",
		first_permission.permission_id, first_permission.round_id).is_applied(),
		"casualty display fixture consumes its player unit")
	_expect(_service.record_casualty(casualty_state, "player_unit_01",
		casualty_state.round_id(), casualty_state.revision()).is_applied(),
		"casualty display fixture records logical death")
	var casualty_text := _presenter.format_status(casualty_state)
	_expect(casualty_text.contains("PLAYER actuaron: player_unit_01"),
		"post-activation casualty remains listed as acted")
	_expect(casualty_text.contains("PLAYER bajas: player_unit_01"),
		"casualty list reflects real BattleState life ledger")

func _test_round_complete_empty_and_invalid() -> void:
	var one_unit := _make_state(1, 0, &"PLAYER")
	var permission: ActivationSchedulerResult = _scheduler.peek(one_unit.scheduler_snapshot())
	_expect(_service.consume_ordinary_activation(one_unit, "player_unit_01",
		permission.permission_id, permission.round_id).is_applied(),
		"round completion fixture consumes its only ordinary activation")
	_expect(_presenter.format_status(one_unit).contains("ROUND_COMPLETE"),
		"presenter displays real round completion")
	_expect(_presenter.format_status(one_unit).contains("no indica victoria/derrota"),
		"presenter does not label round completion as victory or defeat")

	var empty := _make_state(0, 0, &"PLAYER")
	var empty_text: String = _presenter.format_status(empty)
	_expect(empty_text.contains("ROUND_COMPLETE"), "empty BattleState renders ROUND_COMPLETE")
	_expect(empty_text.contains("PLAYER elegibles: —"), "empty player side renders no eligible IDs")
	_expect(empty_text.contains("ENEMY elegibles: —"), "empty enemy side renders no eligible IDs")
	var invalid := BattleStateScript.new()
	_expect(_presenter.format_status(invalid).contains("INVALID_STATE"),
		"uninitialized BattleState is presented as invalid, not as a fabricated turn")
	_expect(_presenter.format_status(null).contains("INVALID_STATE"),
		"null state is presented as invalid")

func _test_queries_are_read_only_and_detached() -> void:
	var state := _make_state(2, 2, &"PLAYER")
	var checkpoint_before: Dictionary = state.to_checkpoint()
	var first: String = _presenter.format_status(state)
	var second: String = _presenter.format_status(state)
	_expect_equal(second, first, "repeated presentation query is deterministic")
	_expect_equal(state.to_checkpoint(), checkpoint_before,
		"presenter must not mutate round, credits, roster, revision or consumption")
	var exposed_ids: Array[String] = state.unit_ids()
	exposed_ids[0] = "forged_id"
	_expect_equal(state.unit_ids()[0], "player_unit_01", "roster enumeration returns a defensive copy")
	_expect_equal(state.to_checkpoint(), checkpoint_before, "mutating returned ID copy leaves state intact")

func _test_presenter_has_no_scene_dependencies() -> void:
	var source: String = FileAccess.get_file_as_string("res://scripts/presentation/battle_status_presenter.gd")
	_expect(not source.contains("extends Node") and not source.contains("SceneTree"),
		"status presenter must remain a non-scene RefCounted adapter")
	_expect(not source.contains("Camera3D") and not source.contains("Sprite3D") and not source.contains("delta"),
		"status presenter must not depend on camera, sprites or FPS")

func _make_state(count_player: int, count_enemy: int, priority: StringName) -> BattleState:
	var ids: Array[String] = []
	var sides: Array[StringName] = []
	for index in count_player:
		ids.append("player_unit_%02d" % (index + 1))
		sides.append(&"PLAYER")
	for index in count_enemy:
		ids.append("enemy_unit_%02d" % (index + 1))
		sides.append(&"ENEMY")
	var state := BattleStateScript.new()
	if not state.configure_round(ids, sides, &"PLAYER", &"ENEMY", priority, 1):
		_failures.append("BattleStatusPresenter fixture failed: %s" % state.error_code())
	return state

func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)

func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [message, expected, actual])
