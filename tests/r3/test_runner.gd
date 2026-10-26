extends SceneTree
## Headless runner for the isolated R3 scheduler-domain suite.

const SchedulerTestsScript = preload("res://tests/r3/test_scheduler.gd")
const ActivationCommandTestsScript = preload("res://tests/r3/test_activation_commands.gd")
const CheckpointTestsScript = preload("res://tests/r3/test_checkpoints.gd")
const BattleStatusPresenterTestsScript = preload("res://tests/r3/test_battle_status_presenter.gd")
const BattleStateScript = preload("res://scripts/r3/battle_state.gd")
const MAIN_SCENE: PackedScene = preload("res://scenes/IsometricArtTest.tscn")

func _initialize() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	var tests: RefCounted = SchedulerTestsScript.new()
	var summary: Dictionary = tests.run()
	var checks: int = int(summary.get("checks", 0))
	var failures: PackedStringArray = summary.get("failures", PackedStringArray())
	for suite_script in [ActivationCommandTestsScript, CheckpointTestsScript, BattleStatusPresenterTestsScript]:
		var suite: RefCounted = suite_script.new()
		var suite_summary: Dictionary = suite.run()
		checks += int(suite_summary.get("checks", 0))
		failures.append_array(suite_summary.get("failures", PackedStringArray()))
	var scene_summary: Dictionary = await _test_live_scene_status_fixture()
	checks += int(scene_summary.get("checks", 0))
	failures.append_array(scene_summary.get("failures", PackedStringArray()))
	if failures.is_empty():
		print("R3 SWRR/activation state + D1 status presenter: %d checks passed" % checks)
		quit(0)
		return
	for failure in failures:
		push_error("R3: " + str(failure))
	push_error("R3 scheduler/status suite: %d checks, %d failures" % [checks, failures.size()])
	quit(1)

func _test_live_scene_status_fixture() -> Dictionary:
	var checks: int = 0
	var failures: PackedStringArray = []
	var scene: Node = MAIN_SCENE.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	var battle_state: BattleState = scene.get("battle_state")
	var hud: Label = scene.get("hud_text")
	if battle_state == null or not battle_state.is_valid():
		failures.append("live scene must initialize an authentic BattleState fixture")
	else:
		checks += 1
		if battle_state.unit_count() != 4:
			failures.append("live scene fixture must contain two stable IDs per side")
		else:
			checks += 1
		if battle_state.eligible_unit_ids_for_side(&"PLAYER").size() != 2 \
			or battle_state.eligible_unit_ids_for_side(&"ENEMY").size() != 2:
			failures.append("live scene fixture must expose 2:2 eligible rosters")
		else:
			checks += 1
	var battle_status: BattleStatusPresenter = scene.get("battle_status_presenter")
	if hud == null or battle_status == null:
		failures.append("live scene must assemble the status presenter into its HUD")
	else:
		checks += 1
		for expected_text in ["TURNOS DEMO", "Ronda: 1", "Bando con permiso: PLAYER",
				"player_unit_01", "enemy_unit_02", "sin asociación a sprites"]:
			if not hud.text.contains(expected_text):
				failures.append("live HUD must display real status text: %s" % expected_text)
			else:
				checks += 1
	var proxy: Sprite3D = scene.get("hero")
	if proxy == null or proxy.texture == null \
		or proxy.texture.resource_path != "res://art/pc001_map_proxy.svg":
		failures.append("live scene continues to display only the versioned proxy actor")
	else:
		checks += 1
	var scene_source: String = FileAccess.get_file_as_string("res://scripts/isometric_art_test.gd")
	if scene_source.contains("consume_ordinary_activation") or scene_source.contains("record_casualty"):
		failures.append("visual scene must not consume activations or mutate casualty state")
	else:
		checks += 1
	if battle_state != null and battle_state.is_valid():
		var before: Dictionary = battle_state.to_checkpoint()
		scene.call("_refresh_hud")
		await process_frame
		if battle_state.to_checkpoint() != before:
			failures.append("HUD refresh must not mutate BattleState")
		else:
			checks += 1
	scene.queue_free()
	await process_frame
	return {"checks": checks, "failures": failures}
