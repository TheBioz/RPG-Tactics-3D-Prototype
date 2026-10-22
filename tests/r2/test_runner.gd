extends SceneTree
## Minimal dependency-free test runner for the R2 logical grid model.

const GridModelScript = preload("res://scripts/r2/grid_model.gd")
const MovementPathfinderTestsScript = preload("res://tests/r2/test_movement_pathfinder.gd")
const MovementCommandTestsScript = preload("res://tests/r2/test_movement_command.gd")
const MAIN_SCENE: PackedScene = preload("res://scenes/IsometricArtTest.tscn")

const CELL_SIZE: float = 1.0
const STEP_Y: float = 0.58
const BASE_Y: float = 0.42
const MOVEMENT_STATE_IDLE: int = 0
const MOVEMENT_STATE_MOVING: int = 1

var _failures: PackedStringArray = []
var _checks: int = 0

func _initialize() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	_test_refcounted_model_and_cell_count()
	_test_bounds_and_invalid_results()
	_test_baseline_heights()
	_test_baseline_surfaces()
	_test_baseline_distributions()
	var movement_tests = MovementPathfinderTestsScript.new()
	var movement_summary: Dictionary = movement_tests.run()
	_checks += int(movement_summary["checks"])
	_failures.append_array(movement_summary["failures"])
	var command_tests = MovementCommandTestsScript.new()
	var command_summary: Dictionary = command_tests.run()
	_checks += int(command_summary["checks"])
	_failures.append_array(command_summary["failures"])
	await _test_camera_controller()
	await _test_scene_interactions()
	await _test_movement_order_flow()
	await _test_delta_partition_independence()
	await _test_movement_resource_lifecycle()
	if _failures.is_empty():
		print("R2-05A/B movement + R2-B2-B regression: %d checks passed" % _checks)
		quit(0)
		return
	for failure in _failures:
		push_error("R2-B2-B: " + failure)
	quit(1)

func _test_refcounted_model_and_cell_count() -> void:
	var model := GridModelScript.new()
	_expect(model is RefCounted, "GridModel must extend RefCounted")
	var model_object: Object = model
	_expect(not (model_object is Node), "GridModel must not depend on the scene tree")
	var valid_count: int = 0
	for z in range(GridModelScript.DEPTH):
		for x in range(GridModelScript.WIDTH):
			if model.contains(Vector2i(x, z)):
				valid_count += 1
	_expect_equal(valid_count, 144, "12x12 grid must contain exactly 144 valid cells")

func _test_bounds_and_invalid_results() -> void:
	var model := GridModelScript.new()
	var invalid_coordinates: Array[Vector2i] = [
		Vector2i(-1, 0), Vector2i(0, -1), Vector2i(-1, -1),
		Vector2i(12, 0), Vector2i(0, 12), Vector2i(12, 12),
	]
	for coordinate in invalid_coordinates:
		_expect(not model.contains(coordinate), "out-of-bounds cell %s must be invalid" % [coordinate])
		_expect_equal(model.height_level_at(coordinate), GridModelScript.INVALID_HEIGHT,
			"invalid cell %s must return INVALID_HEIGHT" % [coordinate])
		_expect_equal(model.surface_kind_at(coordinate), GridModelScript.INVALID_SURFACE,
			"invalid cell %s must return INVALID_SURFACE" % [coordinate])
	_expect_equal(model.height_level_at(Vector2i(3, 0)), 0,
		"invalid queries must not corrupt a later valid height query")
	_expect_equal(model.surface_kind_at(Vector2i(3, 0)), GridModelScript.SurfaceKind.GRASS,
		"invalid queries must not corrupt a later valid surface query")

func _test_baseline_heights() -> void:
	var model := GridModelScript.new()
	_expect_equal(model.height_level_at(Vector2i(3, 3)), 0, "baseline sample must remain height 0")
	_expect_equal(model.height_level_at(Vector2i(6, 6)), 0, "height-0 side of the level boundary must remain 0")
	_expect_equal(model.height_level_at(Vector2i(7, 6)), 1, "baseline sample must remain height 1")
	_expect_equal(model.height_level_at(Vector2i(9, 5)), 1, "height-1 side of the upper boundary must remain 1")
	_expect_equal(model.height_level_at(Vector2i(9, 4)), 2, "baseline sample must remain height 2")
	_expect_equal(model.height_level_at(Vector2i(11, 11)), 0, "bottom-right border height must remain 0")
	_expect_equal(model.height_level_at(Vector2i(11, 0)), 2, "top-right border height must remain 2")
	_expect_equal(model.height_level_at(Vector2i(0, 11)), 1, "bottom-left border height must remain 1")

func _test_baseline_surfaces() -> void:
	var model := GridModelScript.new()
	_expect_equal(model.surface_kind_at(Vector2i(3, 0)), GridModelScript.SurfaceKind.GRASS,
		"baseline grass sample must remain GRASS")
	_expect_equal(model.surface_kind_at(Vector2i(3, 3)), GridModelScript.SurfaceKind.GRASS_B,
		"baseline alternate grass sample must remain GRASS_B")
	_expect_equal(model.surface_kind_at(Vector2i(2, 6)), GridModelScript.SurfaceKind.ROAD,
		"baseline road sample must remain ROAD")
	_expect_equal(model.surface_kind_at(Vector2i(7, 4)), GridModelScript.SurfaceKind.STONE,
		"baseline stone sample must remain STONE")
	_expect_equal(model.surface_kind_at(Vector2i(0, 0)), GridModelScript.SurfaceKind.WATER,
		"baseline water sample must remain WATER")
	_expect_equal(model.surface_kind_at(Vector2i(11, 11)), GridModelScript.SurfaceKind.GRASS_B,
		"bottom-right border surface must remain GRASS_B")
	_expect_equal(model.surface_kind_at(Vector2i(11, 0)), GridModelScript.SurfaceKind.GRASS,
		"top-right border surface must remain GRASS")

func _test_baseline_distributions() -> void:
	var model := GridModelScript.new()
	var height_counts: Array[int] = [0, 0, 0]
	var surface_counts: Array[int] = [0, 0, 0, 0, 0]
	for z in range(GridModelScript.DEPTH):
		for x in range(GridModelScript.WIDTH):
			var coordinate := Vector2i(x, z)
			var height_level: int = model.height_level_at(coordinate)
			var surface_kind: int = model.surface_kind_at(coordinate)
			_expect(height_level >= 0 and height_level < height_counts.size(),
				"every valid cell must have a supported height")
			_expect(surface_kind >= 0 and surface_kind < surface_counts.size(),
				"every valid cell must have a supported surface")
			if height_level >= 0 and height_level < height_counts.size():
				height_counts[height_level] += 1
			if surface_kind >= 0 and surface_kind < surface_counts.size():
				surface_counts[surface_kind] += 1
	_expect_equal(height_counts[0], 100, "baseline height-0 distribution must remain 100 cells")
	_expect_equal(height_counts[1], 29, "baseline height-1 distribution must remain 29 cells")
	_expect_equal(height_counts[2], 15, "baseline height-2 distribution must remain 15 cells")
	_expect_equal(surface_counts[GridModelScript.SurfaceKind.GRASS], 81,
		"baseline GRASS distribution must remain 81 cells")
	_expect_equal(surface_counts[GridModelScript.SurfaceKind.GRASS_B], 24,
		"baseline GRASS_B distribution must remain 24 cells")
	_expect_equal(surface_counts[GridModelScript.SurfaceKind.ROAD], 26,
		"baseline ROAD distribution must remain 26 cells")
	_expect_equal(surface_counts[GridModelScript.SurfaceKind.STONE], 4,
		"baseline STONE distribution must remain 4 cells")
	_expect_equal(surface_counts[GridModelScript.SurfaceKind.WATER], 9,
		"baseline WATER distribution must remain 9 cells")

func _test_camera_controller() -> void:
	var camera := CameraController.new()
	root.add_child(camera)
	await process_frame
	_expect_equal(camera.projection, Camera3D.PROJECTION_ORTHOGONAL,
		"camera controller must use orthographic projection")
	_expect_equal(camera.yaw_degrees, 45.0, "camera yaw must match the baseline")
	_expect_equal(camera.pitch_degrees, 50.0, "camera pitch must match the baseline")
	_expect_equal(camera.orthographic_size, 17.0, "camera zoom must match the baseline")
	_expect(_vector3_is_equal(camera.position, _expected_camera_position(45.0, 50.0)),
		"initial camera position must match the baseline orientation formula")
	_expect(_vector3_is_equal((-camera.global_basis.z).normalized(),
		(camera.global_position.direction_to(Vector3(6.0, 0.65, 6.0))).normalized()),
		"camera forward transform must point at the fixed baseline focus")
	_expect(is_equal_approx(camera.size, 17.0), "initial effective orthographic size must be 17")

	for yaw in [0.0, 90.0, 180.0, 270.0]:
		_expect(camera.apply_rotation_deltas(yaw - camera.yaw_degrees, 0.0),
			"camera must accept each cardinal yaw")
		_expect(_vector3_is_equal(camera.position, _expected_camera_position(yaw, 50.0)),
			"cardinal yaw %s must produce the baseline camera position" % yaw)
		_expect(_vector3_is_equal((-camera.global_basis.z).normalized(),
			camera.global_position.direction_to(Vector3(6.0, 0.65, 6.0)).normalized()),
			"cardinal yaw %s must preserve the real camera look transform" % yaw)

	for pitch in [25.0, 50.0, 78.0]:
		_expect(camera.apply_rotation_deltas(0.0, pitch - camera.pitch_degrees),
			"camera must accept baseline pitch %s" % pitch)
		_expect(_vector3_is_equal(camera.position, _expected_camera_position(270.0, pitch)),
			"pitch %s must produce the baseline camera position" % pitch)
		_expect(_vector3_is_equal((-camera.global_basis.z).normalized(),
			camera.global_position.direction_to(Vector3(6.0, 0.65, 6.0)).normalized()),
			"pitch %s must preserve the real camera look transform" % pitch)

	for zoom in [8.0, 17.0, 24.0]:
		_expect(camera.apply_zoom_delta(zoom - camera.orthographic_size),
			"camera must accept baseline zoom %s" % zoom)
		_expect(is_equal_approx(camera.size, zoom), "zoom %s must update Camera3D.size" % zoom)
	_expect(camera.apply_rotation_deltas(0.0, 1000.0), "pitch above maximum must clamp")
	_expect_equal(camera.pitch_degrees, 78.0, "pitch must clamp at 78 degrees")
	_expect(camera.apply_rotation_deltas(0.0, -1000.0), "pitch below minimum must clamp")
	_expect_equal(camera.pitch_degrees, 25.0, "pitch must clamp at 25 degrees")
	_expect(camera.apply_zoom_delta(-1000.0), "zoom below minimum must clamp")
	_expect_equal(camera.orthographic_size, 8.0, "zoom must clamp at 8")
	_expect(camera.apply_zoom_delta(1000.0), "zoom above maximum must clamp")
	_expect_equal(camera.orthographic_size, 24.0, "zoom must clamp at 24")
	var before_invalid_position: Vector3 = camera.position
	var before_invalid_yaw: float = camera.yaw_degrees
	var before_invalid_pitch: float = camera.pitch_degrees
	var before_invalid_zoom: float = camera.orthographic_size
	_expect(not camera.apply_rotation_deltas(INF, 1.0), "non-finite yaw delta must be rejected")
	_expect(not camera.apply_rotation_deltas(1.0, NAN), "non-finite pitch delta must be rejected")
	_expect(not camera.apply_zoom_delta(INF), "non-finite zoom delta must be rejected")
	_expect_equal(camera.yaw_degrees, before_invalid_yaw, "invalid yaw input must not partially mutate yaw")
	_expect_equal(camera.pitch_degrees, before_invalid_pitch, "invalid camera input must not partially mutate pitch")
	_expect_equal(camera.orthographic_size, before_invalid_zoom, "invalid camera input must not mutate zoom")
	_expect(_vector3_is_equal(camera.position, before_invalid_position), "invalid inputs must not move camera")

	camera.reset_camera()
	_expect_equal(camera.yaw_degrees, 45.0, "reset must restore baseline yaw")
	_expect_equal(camera.pitch_degrees, 50.0, "reset must restore baseline pitch")
	_expect_equal(camera.orthographic_size, 17.0, "reset must restore baseline zoom")
	_expect(_vector3_is_equal(camera.position, _expected_camera_position(45.0, 50.0)),
		"reset must restore the real baseline transform")

	var fast_camera := CameraController.new()
	var slow_camera := CameraController.new()
	root.add_child(fast_camera)
	root.add_child(slow_camera)
	for _frame in 60:
		fast_camera.apply_rotation_deltas(CameraController.YAW_DEGREES_PER_SECOND / 60.0,
			CameraController.PITCH_DEGREES_PER_SECOND / 60.0)
	for _frame in 30:
		slow_camera.apply_rotation_deltas(CameraController.YAW_DEGREES_PER_SECOND / 30.0,
			CameraController.PITCH_DEGREES_PER_SECOND / 30.0)
	_expect(is_equal_approx(fast_camera.yaw_degrees, slow_camera.yaw_degrees)
		and is_equal_approx(fast_camera.pitch_degrees, slow_camera.pitch_degrees),
		"equal simulated input intervals must be frame-rate independent")

	camera.size = 800.0
	camera.position = _expected_camera_position(45.0, 50.0)
	camera.look_at(Vector3(6.0, 0.65, 6.0), Vector3.UP)
	var ray: Dictionary = camera.screen_ray(camera.get_viewport().get_visible_rect().size * 0.5)
	_expect(not ray.is_empty(), "screen center must produce a picking ray")
	if not ray.is_empty():
		var ray_from: Vector3 = ray["from"]
		var ray_to: Vector3 = ray["to"]
		_expect(absf(ray_from.distance_to(ray_to) - CameraController.PICK_DISTANCE) < 0.001,
			"screen picking ray must preserve the 170-unit baseline distance")
		_expect(ray_from.direction_to(ray_to).dot(camera.global_position.direction_to(Vector3(6.0, 0.65, 6.0))) > 0.999,
			"center-screen ray must point along camera forward")
	_expect(camera.screen_ray(Vector2(INF, 0.0)).is_empty(),
		"non-finite screen coordinate must not produce a ray")
	fast_camera.queue_free()
	slow_camera.queue_free()
	camera.queue_free()
	await process_frame

func _expected_camera_position(yaw_degrees: float, pitch_degrees: float) -> Vector3:
	var yaw := deg_to_rad(yaw_degrees)
	var pitch := deg_to_rad(pitch_degrees)
	var offset := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * 24.0
	return Vector3(6.0, 0.65, 6.0) + offset

func _test_scene_interactions() -> void:
	var scene := MAIN_SCENE.instantiate()
	root.add_child(scene)
	await process_frame

	var model: GridModel = scene.get("grid_model")
	var grid_view: GridView = scene.get("grid_view")
	var camera: CameraController = scene.get_node("Camera3D")
	var hero: Sprite3D = scene.get("hero")
	var shadow: MeshInstance3D = scene.get("hero_shadow")
	var selection_overlay: MeshInstance3D = grid_view.get_node("SelectedTile")
	var initial_selected: Vector2i = scene.get("selected_coordinate")
	_expect_equal(initial_selected, Vector2i(5, 6), "scene must start with the original logical selection")
	_test_grid_view(grid_view, model, initial_selected)
	var initial_actor: Vector2i = scene.get("actor_coordinate")
	var initial_selection: Vector2i = scene.get("selected_coordinate")
	var initial_hero_position: Vector3 = hero.position
	var initial_shadow_position: Vector3 = shadow.position
	var initial_actor_surface_y: float = BASE_Y + float(model.height_level_at(initial_actor)) * STEP_Y
	var high_cell := Vector2i(7, 6)
	var imported_height: int = hero.texture.get_height()
	var initial_pixel_size: float = hero.pixel_size
	print("B1-ANCHOR proxy import: %dx%d, pixel_size=%.8f, centered=%s, center_y=%.8f, surface_y=%.8f" % [
		hero.texture.get_width(), imported_height, initial_pixel_size, hero.centered,
		initial_hero_position.y, initial_actor_surface_y,
	])

	_expect_equal(initial_actor, Vector2i(5, 6), "actor logical cell must initialize at (5,6)")
	_expect_equal(initial_selection, Vector2i(5, 6), "selection must initialize at (5,6)")
	_expect_equal(camera.yaw_degrees, 45.0, "scene camera must start at baseline yaw")
	_expect_equal(camera.pitch_degrees, 50.0, "scene camera must start at baseline pitch")
	_expect_equal(camera.orthographic_size, 17.0, "scene camera must start at baseline zoom")
	var pick_coordinate := Vector2i(6, 6)
	var pick_world_position: Vector3 = grid_view.world_position_for_cell(pick_coordinate)
	var pick_screen_position: Vector2 = camera.unproject_position(pick_world_position)
	var pick_ray: Dictionary = camera.screen_ray(pick_screen_position)
	_expect(not pick_ray.is_empty(), "projected real tile coordinate must produce a camera ray")
	if not pick_ray.is_empty():
		var pick_query := PhysicsRayQueryParameters3D.create(pick_ray["from"], pick_ray["to"])
		var pick_hit: Dictionary = scene.get_world_3d().direct_space_state.intersect_ray(pick_query)
		_expect(not pick_hit.is_empty(), "camera ray must physically intersect the real grid collider")
		if not pick_hit.is_empty():
			_expect(scene.call("select_grid_collider", pick_hit.get("collider")),
				"physical camera hit must select through the existing GridView validation")
			_expect_equal(scene.get("selected_coordinate"), pick_coordinate,
				"physical camera hit must select the projected real cell")
	var selection_before_camera_change: Vector2i = scene.get("selected_coordinate")
	var actor_before_camera_change: Vector2i = scene.get("actor_coordinate")
	camera.apply_rotation_deltas(45.0, 10.0)
	camera.apply_zoom_delta(-2.0)
	_expect_equal(scene.get("selected_coordinate"), selection_before_camera_change,
		"camera changes must not mutate selected_coordinate")
	_expect_equal(scene.get("actor_coordinate"), actor_before_camera_change,
		"camera changes must not mutate actor_coordinate")
	camera.reset_camera()
	_expect(_vector3_is_equal(camera.position, _expected_camera_position(45.0, 50.0)),
		"scene HOME reset contract must restore camera transform")
	_expect(imported_height > 0 and initial_pixel_size > 0.0,
		"initial proxy texture dimensions and scale must be positive")
	_expect(hero.centered, "Sprite3D pivot must be centered for contact-point calculation")
	var initial_half_height: float = float(imported_height) * initial_pixel_size * 0.5
	_expect(absf(initial_hero_position.y - (initial_actor_surface_y + initial_half_height)) < 0.0001,
		"initial sprite center must match imported texture height and scale")
	_expect(absf(initial_hero_position.y - initial_half_height - initial_actor_surface_y) < 0.0001,
		"initial proxy feet must contact its model surface")
	_expect(absf(initial_shadow_position.y - (initial_actor_surface_y + 0.048)) < 0.0001,
		"initial proxy shadow must contact its model surface")

	# Regression: move the fresh scene's actor before apply_actor_texture() normalizes its scale.
	_expect(scene.call("move_actor_to", high_cell), "fresh actor must move to a valid elevated cell")
	_expect_equal(scene.get("actor_coordinate"), high_cell,
		"cold move must update the actor logical cell")
	var high_surface_y: float = BASE_Y + float(model.height_level_at(high_cell)) * STEP_Y
	var cold_sprite: Sprite3D = scene.get("hero")
	var cold_shadow: MeshInstance3D = scene.get("hero_shadow")
	var cold_half_height: float = float(cold_sprite.texture.get_height()) * cold_sprite.pixel_size * 0.5
	_expect(absf(cold_sprite.position.y - cold_half_height - high_surface_y) < 0.0001,
		"moving before texture change must keep proxy feet on the elevated surface")
	_expect(absf(cold_shadow.position.y - (high_surface_y + 0.048)) < 0.0001,
		"moving before texture change must keep the shadow on the elevated surface")
	_expect(is_equal_approx(cold_sprite.position.x, 7.5) and is_equal_approx(cold_sprite.position.z, 6.5),
		"cold move must position sprite at the target cell center")

	var cold_actor_position: Vector3 = cold_sprite.position
	var cold_shadow_position: Vector3 = cold_shadow.position
	_expect(scene.call("select_cell", Vector2i(3, 0)), "a cell different from the actor may be selected")
	_expect_equal(scene.get("selected_coordinate"), Vector2i(3, 0),
		"selection must update independently of the actor")
	_expect(_vector3_is_equal(selection_overlay.position,
		grid_view.world_position_for_cell(Vector2i(3, 0)) + Vector3(0.0, 0.07, 0.0)),
		"valid selection must update the GridView highlight")
	_expect_equal(scene.get("actor_coordinate"), high_cell,
		"selecting elsewhere must retain the actor's logical coordinate")
	_expect(cold_sprite.position.distance_to(cold_actor_position) < 0.0001,
		"selecting elsewhere must not move the actor sprite")
	_expect(cold_shadow.position.distance_to(cold_shadow_position) < 0.0001,
		"selecting elsewhere must not move the actor shadow")

	var proxy_texture: Texture2D = load("res://art/pc001_map_proxy.svg")
	_expect(scene.call("apply_actor_texture", proxy_texture),
		"versioned proxy texture must be accepted without the private PNG")
	_expect_equal(scene.get("actor_coordinate"), high_cell,
		"changing actor texture must retain its logical cell")
	var actor_sprite_bottom_y: float = cold_sprite.position.y \
		- float(cold_sprite.texture.get_height()) * cold_sprite.pixel_size * 0.5
	_expect(absf(actor_sprite_bottom_y - high_surface_y) < 0.0001,
		"changing actor texture with a different selection must keep the sprite feet on the actor cell")
	_expect(is_equal_approx(cold_sprite.position.x, 7.5)
		and is_equal_approx(cold_sprite.position.z, 6.5),
		"changing actor texture with a different selection must retain actor X/Z")
	_expect(cold_shadow.position.distance_to(cold_shadow_position) < 0.0001,
		"changing actor texture with a different selection must retain shadow anchor")

	var invalid_texture := ImageTexture.new()
	_expect(invalid_texture.get_width() <= 0 or invalid_texture.get_height() <= 0,
		"invalid texture fixture must have a non-positive dimension")
	var actor_before_invalid_texture: Vector2i = scene.get("actor_coordinate")
	var texture_before_invalid: Texture2D = cold_sprite.texture
	var pixel_size_before_invalid: float = cold_sprite.pixel_size
	var hero_position_before_invalid: Vector3 = cold_sprite.position
	var shadow_position_before_invalid: Vector3 = cold_shadow.position
	_expect(not scene.call("apply_actor_texture", invalid_texture),
		"texture with invalid dimensions must be rejected")
	_expect_equal(scene.get("actor_coordinate"), actor_before_invalid_texture,
		"invalid texture must not mutate actor coordinate")
	_expect(cold_sprite.texture == texture_before_invalid
		and is_equal_approx(cold_sprite.pixel_size, pixel_size_before_invalid),
		"invalid texture must not mutate texture or pixel size")
	_expect(cold_sprite.position.distance_to(hero_position_before_invalid) < 0.0001,
		"invalid texture must not move actor sprite")
	_expect(cold_shadow.position.distance_to(shadow_position_before_invalid) < 0.0001,
		"invalid texture must not move actor shadow")

	var valid_collider: StaticBody3D = _find_grid_collider(scene, Vector2i(3, 0))
	_expect(valid_collider != null, "scene must expose colliders with both tile metadata keys")
	if valid_collider != null:
		_expect(scene.call("select_grid_collider", valid_collider),
			"valid grid collider must select its model coordinate")
		_expect_equal(scene.get("selected_coordinate"), Vector2i(3, 0),
			"collider selection must map tile_x and tile_z")
		_expect_equal(scene.get("actor_coordinate"), high_cell,
			"collider selection must not move the actor")
		var selected_before_metadata_change: Vector2i = scene.get("selected_coordinate")
		var original_tile_z: Variant = valid_collider.get_meta("tile_z")
		var original_height: Variant = valid_collider.get_meta("height_level")
		valid_collider.set_meta("tile_z", int(original_tile_z) + 1)
		_expect(not scene.call("select_grid_collider", valid_collider),
			"registered collider with altered tile_z must be rejected")
		_expect_equal(scene.get("selected_coordinate"), selected_before_metadata_change,
			"altered tile_z must not mutate selection")
		valid_collider.set_meta("tile_z", original_tile_z)
		valid_collider.set_meta("height_level", int(original_height) + 1)
		_expect(not scene.call("select_grid_collider", valid_collider),
			"registered collider with altered height must be rejected")
		_expect_equal(scene.get("selected_coordinate"), selected_before_metadata_change,
			"altered height must not mutate selection")
		valid_collider.set_meta("height_level", original_height)
		_expect(scene.call("select_grid_collider", valid_collider),
			"restored registered collider metadata must be accepted")
		_expect_equal(scene.get("selected_coordinate"), Vector2i(3, 0),
			"restored collider metadata must select its registered coordinate")

	var selected_before_invalid: Vector2i = scene.get("selected_coordinate")
	var overlay_before_invalid: Vector3 = selection_overlay.position
	var view_spoof := StaticBody3D.new()
	grid_view.add_child(view_spoof)
	view_spoof.add_to_group("grid_tile")
	view_spoof.set_meta("tile_x", 7)
	view_spoof.set_meta("tile_z", 6)
	view_spoof.set_meta("height_level", model.height_level_at(Vector2i(7, 6)))
	_expect(grid_view.coordinate_from_collider(view_spoof) == GridView.INVALID_COORDINATE,
		"valid-looking child of GridView must be rejected if it was not registered")
	_expect(not scene.call("select_grid_collider", view_spoof),
		"valid-looking unregistered GridView child must not select a cell")
	view_spoof.free()
	var fake_collider := StaticBody3D.new()
	scene.add_child(fake_collider)
	fake_collider.add_to_group("grid_tile")
	fake_collider.set_meta("tile_x", 7)
	fake_collider.set_meta("tile_z", 6)
	fake_collider.set_meta("height_level", model.height_level_at(Vector2i(7, 6)))
	_expect(grid_view.coordinate_from_collider(fake_collider) == GridView.INVALID_COORDINATE,
		"valid-looking collider outside GridView must not be registered")
	_expect(not scene.call("select_grid_collider", fake_collider),
		"valid-looking external collider must not select a cell")
	fake_collider.set_meta("tile_x", 4)
	fake_collider.remove_meta("tile_z")
	fake_collider.remove_meta("height_level")
	_expect(not scene.call("select_grid_collider", fake_collider),
		"collider missing tile_z must be rejected")
	fake_collider.set_meta("tile_z", 4)
	fake_collider.set_meta("height_level", 99)
	_expect(not scene.call("select_grid_collider", fake_collider),
		"collider with a mismatched height must be rejected")
	fake_collider.set_meta("tile_x", 12)
	fake_collider.set_meta("height_level", 0)
	_expect(not scene.call("select_grid_collider", fake_collider),
		"out-of-bounds collider metadata must be rejected")
	fake_collider.free()
	_expect_equal(scene.get("selected_coordinate"), selected_before_invalid,
		"invalid collider attempts must not mutate selection")
	_expect(_vector3_is_equal(selection_overlay.position, overlay_before_invalid),
		"invalid collider attempts must not move the selection highlight")

	_expect(scene.call("move_actor_to", initial_actor),
		"actor must move to a lower cell after texture replacement")
	_expect_equal(scene.get("actor_coordinate"), initial_actor,
		"lower-height move must update actor logical coordinate")
	var low_surface_y: float = BASE_Y + float(model.height_level_at(initial_actor)) * STEP_Y
	var low_sprite_bottom_y: float = cold_sprite.position.y \
		- float(cold_sprite.texture.get_height()) * cold_sprite.pixel_size * 0.5
	_expect(absf(low_sprite_bottom_y - low_surface_y) < 0.0001,
		"post-texture lower-height move must keep sprite feet on the surface")
	_expect(absf(cold_shadow.position.y - (low_surface_y + 0.048)) < 0.0001,
		"post-texture lower-height move must keep shadow aligned")
	_expect(scene.call("move_actor_to", high_cell),
		"actor must move back to the elevated cell after texture replacement")
	_expect_equal(scene.get("actor_coordinate"), high_cell,
		"elevated move must update actor logical coordinate")
	var returned_sprite_bottom_y: float = cold_sprite.position.y \
		- float(cold_sprite.texture.get_height()) * cold_sprite.pixel_size * 0.5
	_expect(absf(returned_sprite_bottom_y - high_surface_y) < 0.0001,
		"post-texture elevated move must keep sprite feet on the surface")
	_expect(absf(cold_shadow.position.y - (high_surface_y + 0.048)) < 0.0001,
		"post-texture elevated move must keep shadow aligned")

	var moved_actor: Vector2i = scene.get("actor_coordinate")
	var moved_hero_position: Vector3 = cold_sprite.position
	var moved_shadow_position: Vector3 = cold_shadow.position
	_expect(scene.call("select_cell", Vector2i(0, 0)), "water cell may be selected")
	_expect(not scene.call("move_actor_to", scene.get("selected_coordinate")),
		"moving the test actor onto water must be rejected")
	_expect_equal(scene.get("actor_coordinate"), moved_actor,
		"water destination must not mutate the actor coordinate")
	_expect(cold_sprite.position.distance_to(moved_hero_position) < 0.0001,
		"water destination must not move the actor sprite")
	_expect(cold_shadow.position.distance_to(moved_shadow_position) < 0.0001,
		"water destination must not move the actor shadow")
	_expect(not scene.call("move_actor_to", Vector2i(12, 12)),
		"moving the test actor outside the grid must be rejected")
	_expect_equal(scene.get("actor_coordinate"), moved_actor,
		"out-of-bounds destination must not mutate the actor coordinate")
	_expect(cold_sprite.position.distance_to(moved_hero_position) < 0.0001,
		"out-of-bounds destination must not move the actor sprite")
	_expect(cold_shadow.position.distance_to(moved_shadow_position) < 0.0001,
		"out-of-bounds destination must not move the actor shadow")

	var selected_before_invalid_cell: Vector2i = scene.get("selected_coordinate")
	var overlay_before_invalid_cell: Vector3 = selection_overlay.position
	_expect(not scene.call("select_cell", Vector2i(12, 12)), "out-of-bounds cell must not be selectable")
	_expect_equal(scene.get("selected_coordinate"), selected_before_invalid_cell,
		"invalid cell selection must not mutate selection")
	_expect(_vector3_is_equal(selection_overlay.position, overlay_before_invalid_cell),
		"invalid cell selection must leave the current highlight unchanged")
	_expect_equal(scene.get("actor_coordinate"), moved_actor,
		"invalid cell selection must not mutate the actor")

	var released_collider: StaticBody3D = _find_grid_collider(scene, Vector2i(0, 4))
	var released_reference: WeakRef = weakref(released_collider)
	released_collider.free()
	var freed_collider: Variant = released_reference.get_ref()
	_expect(freed_collider == null, "freed collider weak reference must expire")
	_expect_equal(grid_view.coordinate_from_collider(freed_collider), GridView.INVALID_COORDINATE,
		"freed collider must be rejected by GridView")

	scene.queue_free()
	await process_frame

func _test_movement_order_flow() -> void:
	var scene := MAIN_SCENE.instantiate()
	root.add_child(scene)
	await process_frame
	var grid_view: GridView = scene.get("grid_view")
	var hero: Sprite3D = scene.get("hero")
	var shadow: MeshInstance3D = scene.get("hero_shadow")
	var start: Vector2i = scene.get("actor_coordinate")
	var grid_model: GridModel = scene.get("grid_model")
	var grid_snapshot: Dictionary = _grid_model_snapshot(grid_model)
	var initial_hero_position: Vector3 = hero.position
	var initial_shadow_position: Vector3 = shadow.position
	var route_overlay: Node3D = grid_view.get_node("RoutePreview")
	var collider_count_before_preview: int = scene.get_tree().get_nodes_in_group("grid_tile").size()
	var target := Vector2i(7, 6)
	var target_screen_position: Vector2 = scene.get_node("Camera3D").unproject_position(
		grid_view.world_position_for_cell(target)
	)
	var target_click := InputEventMouseButton.new()
	target_click.button_index = MOUSE_BUTTON_LEFT
	target_click.pressed = true
	target_click.position = target_screen_position
	scene.call("_unhandled_input", target_click)
	_expect_equal(scene.get("selected_coordinate"), target,
		"clicking a real grid collider must update the selected destination")
	_expect_equal(scene.get("actor_coordinate"), start,
		"selection preview must not move the actor logically")
	_expect(hero.position.distance_to(initial_hero_position) < 0.0001
		and shadow.position.distance_to(initial_shadow_position) < 0.0001,
		"selection preview must not move sprite or shadow")
	var preview: MovementCommandResult = scene.get("movement_preview")
	_expect_equal(preview.status, MovementCommandResult.Status.ACCEPTED,
		"legal clicked destination must produce an accepted preview")
	_expect_equal(preview.total_cost, 3, "preview must display the exact path cost")
	_expect_equal(route_overlay.get_child_count(), preview.path.size() - 1,
		"route preview must mark each traversed cell after the actor origin")
	_expect_equal(scene.get_tree().get_nodes_in_group("grid_tile").size(), collider_count_before_preview,
		"route preview must not add or alter picking colliders")

	var preview_before_invalid: MovementCommandResult = scene.get("movement_preview")
	_expect(not scene.call("select_cell", Vector2i(12, 12)),
		"out-of-bounds selection must be rejected")
	_expect_equal(scene.get("selected_coordinate"), target,
		"invalid selection must preserve current destination")
	_expect(scene.get("movement_preview") == preview_before_invalid,
		"invalid selection must preserve preview for unchanged destination")

	_expect(scene.call("select_cell", Vector2i(2, 2)), "water cell remains selectable for feedback")
	_expect_equal(scene.get("movement_preview").status,
		MovementCommandResult.Status.ILLEGAL_DESTINATION,
		"water selection must produce an illegal-destination reason")
	_expect_equal(route_overlay.get_child_count(), 0,
		"illegal destination must clear the old legal route")
	_expect_equal(scene.get("actor_coordinate"), start,
		"illegal preview must not mutate actor coordinate")

	var over_budget := Vector2i(9, 4)
	_expect(scene.call("select_cell", over_budget), "far legal cell must be selectable")
	_expect_equal(scene.get("movement_preview").status,
		MovementCommandResult.Status.INSUFFICIENT_BUDGET,
		"over-budget destination must be reported")
	_expect_equal(route_overlay.get_child_count(), 0,
		"diagnostic over-budget route must not be drawn as authorized")
	_expect(not scene.call("_confirm_move_order"), "over-budget TAB confirmation must be rejected")
	_expect_equal(scene.get("actor_coordinate"), start,
		"over-budget confirmation must not move actor")

	_expect(scene.call("select_cell", target), "legal destination can be reselected")
	_expect(scene.call("move_actor_to", Vector2i(11, 11)),
		"test setup helper can change origin between preview and confirmation")
	_expect_equal(scene.get("movement_preview").status, MovementCommandResult.Status.ACCEPTED,
		"previous preview remains only a preview after test state changes")
	_expect(not scene.call("_confirm_move_order"),
		"confirmation must re-evaluate from the current actor coordinate")
	_expect(scene.get("movement_preview") == null,
		"confirmation must clear the previous preview result even when rejected")
	_expect(str(scene.get("movement_message")).contains("supera el presupuesto"),
		"revalidation must report the updated route cost in the HUD message")
	_expect_equal(scene.get("actor_coordinate"), Vector2i(11, 11),
		"rejected stale preview must preserve the current actor origin")
	_expect(scene.call("move_actor_to", start), "test setup helper restores original actor cell")
	_expect(scene.call("select_cell", target), "reselecting target must calculate a fresh preview")

	var available_shadow: MeshInstance3D = scene.get("hero_shadow")
	scene.set("hero_shadow", null)
	_expect(not scene.call("_confirm_move_order"),
		"missing shadow must reject before committing a logical move")
	_expect_equal(scene.get("actor_coordinate"), start,
		"missing presentation resource must leave actor coordinate unchanged")
	scene.set("hero_shadow", available_shadow)
	_expect(scene.call("select_cell", target), "target preview must be refreshed after resource restoration")

	var props: Node3D = scene.get("prop_root")
	var hide_props := InputEventKey.new()
	hide_props.keycode = KEY_B
	hide_props.pressed = true
	scene.call("_unhandled_input", hide_props)
	_expect(not props.visible, "B must still hide props in C1")
	_expect(not scene.call("_confirm_move_order"),
		"movement must be rejected while actor presentation is hidden")
	_expect_equal(scene.get("actor_coordinate"), start,
		"hidden actor must not receive a logical movement update")
	var show_props := InputEventKey.new()
	show_props.keycode = KEY_B
	show_props.pressed = true
	scene.call("_unhandled_input", show_props)
	_expect(props.visible, "B must restore actor presentation")

	scene.set_process(false)
	scene.get_node("Camera3D").apply_rotation_deltas(30.0, 5.0)
	var tab := InputEventKey.new()
	tab.keycode = KEY_TAB
	tab.pressed = true
	scene.call("_unhandled_input", tab)
	_expect_equal(scene.get("actor_coordinate"), target,
		"accepted TAB must commit the logical destination exactly once")
	_expect_equal(int(scene.get("movement_state")), MOVEMENT_STATE_MOVING,
		"accepted TAB must enter MOVING state")
	var accepted_path: Array[Vector2i] = scene.get("accepted_path")
	_expect_equal(accepted_path, [start, Vector2i(6, 6), target],
		"execution must copy the newly validated complete route")
	_expect(scene.get("movement_preview") == null,
		"confirmation must clear the previsualization result")
	_expect(hero.position.distance_to(initial_hero_position) < 0.0001,
		"acceptance must not snap the sprite to destination before route progression")
	_expect_equal(route_overlay.get_child_count(), accepted_path.size() - 1,
		"accepted route markers must remain visible during MOVING")

	var blocked_click := InputEventMouseButton.new()
	blocked_click.button_index = MOUSE_BUTTON_LEFT
	blocked_click.pressed = true
	blocked_click.position = target_screen_position
	scene.call("_unhandled_input", blocked_click)
	_expect_equal(scene.get("selected_coordinate"), target,
		"left click must not replace selection while MOVING")
	var repeated_tab := InputEventKey.new()
	repeated_tab.keycode = KEY_TAB
	repeated_tab.pressed = true
	scene.call("_unhandled_input", repeated_tab)
	_expect_equal(scene.get("accepted_path"), accepted_path,
		"repeated TAB must not replace or execute the accepted route")
	var v_event := InputEventKey.new()
	v_event.keycode = KEY_V
	v_event.pressed = true
	scene.set("reference_texture", load("res://art/pc001_map_proxy.svg"))
	scene.call("_unhandled_input", v_event)
	_expect(not scene.get("use_reference"), "V must not change texture during MOVING")
	var b_event := InputEventKey.new()
	b_event.keycode = KEY_B
	b_event.pressed = true
	scene.call("_unhandled_input", b_event)
	_expect(props.visible, "B must not hide props during MOVING")
	var grid_event := InputEventKey.new()
	grid_event.keycode = KEY_G
	grid_event.pressed = true
	scene.call("_unhandled_input", grid_event)
	_expect(not grid_view.get_node("GridOverlay").visible,
		"G grid visibility control must remain available during MOVING")
	scene.call("_unhandled_input", grid_event)
	_expect(grid_view.get_node("GridOverlay").visible, "G must restore grid visibility during MOVING")
	scene.get_node("Camera3D").reset_camera()
	_expect_equal(scene.get("actor_coordinate"), target,
		"camera controls must not change the confirmed logical destination")

	var intermediate_surface: Vector3 = grid_view.world_position_for_cell(Vector2i(6, 6))
	var half_height: float = float(hero.texture.get_height()) * hero.pixel_size * 0.5
	scene.call("_advance_movement", 0.2)
	_expect_equal(int(scene.get("movement_state")), MOVEMENT_STATE_MOVING,
		"first cell step must leave the remaining route in progress")
	_expect(_vector3_is_equal(hero.position,
		intermediate_surface + Vector3(0.0, half_height, 0.0)),
		"movement must visibly visit the intermediate cell")
	_expect_equal(scene.get("actor_coordinate"), target,
		"route presentation must not alter the already committed logical destination")

	var lower_surface_y: float = intermediate_surface.y
	var upper_surface_y: float = grid_view.world_position_for_cell(target).y
	scene.call("_advance_movement", 0.1)
	var transition_surface_y := lerpf(lower_surface_y, upper_surface_y, 0.5)
	_expect(_vector3_is_equal(hero.position, Vector3(7.0, transition_surface_y + half_height, 6.5)),
		"height change must use the boundary transition phase")
	_expect(absf(shadow.position.y - (lower_surface_y + 0.048)) < 0.0001,
		"shadow must stay on the lower support surface during ascent")
	scene.call("_advance_movement", 0.1)
	_expect_equal(int(scene.get("movement_state")), MOVEMENT_STATE_IDLE,
		"finishing the route must return to IDLE")
	var destination_surface: Vector3 = grid_view.world_position_for_cell(target)
	_expect(absf(hero.position.y - half_height - destination_surface.y) < 0.0001,
		"completed route must place actor feet exactly at the destination")
	_expect(absf(shadow.position.y - (destination_surface.y + 0.048)) < 0.0001,
		"completed route must anchor shadow at the destination surface")
	_expect_equal(route_overlay.get_child_count(), 0, "completed route must clear its visual markers")
	_expect((scene.get("accepted_path") as Array[Vector2i]).is_empty(),
		"completion must clear the accepted route")
	_expect(scene.get("movement_preview") == null,
		"completion must keep the preview result cleared")

	var actor_before_camera: Vector2i = scene.get("actor_coordinate")
	var selection_before_camera: Vector2i = scene.get("selected_coordinate")
	_expect_equal(grid_model.height_level_at(target), 1,
		"movement presentation must not modify the GridModel")
	_expect_equal(_grid_model_snapshot(grid_model), grid_snapshot,
		"animation must not mutate any GridModel cell")
	_expect_equal(scene.get("actor_coordinate"), actor_before_camera,
		"logical actor coordinate must remain at its committed endpoint")
	_expect_equal(scene.get("selected_coordinate"), selection_before_camera,
		"logical selection must remain unchanged through route presentation")
	scene.queue_free()
	await process_frame

func _test_delta_partition_independence() -> void:
	var single_advance: Array[float] = [0.4]
	var regular_advances: Array[float] = [0.1, 0.1, 0.1, 0.1]
	var irregular_advances: Array[float] = [0.07, 0.13, 0.09, 0.11]
	var one_step_result := await _run_route_with_deltas(single_advance, true)
	var regular_result := await _run_route_with_deltas(regular_advances, false)
	var irregular_result := await _run_route_with_deltas(irregular_advances, false)
	for result in [one_step_result, regular_result, irregular_result]:
		_expect_equal(result["actor"], Vector2i(7, 6),
			"all delta partitions must commit the same logical destination")
		_expect_equal(result["state"], MOVEMENT_STATE_IDLE,
			"equal total time must finish movement in IDLE")
		_expect_equal(result["accepted_path_empty"], true,
			"all delta partitions must clear the accepted route")
		_expect_equal(result["preview_cleared"], true,
			"all delta partitions must clear preview state")
		_expect_equal(result["route_marker_count"], 0,
			"all delta partitions must clear route markers")
	_expect(_vector3_is_equal(one_step_result["hero"], regular_result["hero"])
		and _vector3_is_equal(one_step_result["hero"], irregular_result["hero"]),
		"different delta partitions must produce the exact same final sprite position")
	_expect(_vector3_is_equal(one_step_result["shadow"], regular_result["shadow"])
		and _vector3_is_equal(one_step_result["shadow"], irregular_result["shadow"]),
		"different delta partitions must produce the exact same final shadow position")

func _run_route_with_deltas(deltas: Array[float], check_invalid_deltas: bool) -> Dictionary:
	var scene := MAIN_SCENE.instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	var grid_view: GridView = scene.get("grid_view")
	var hero: Sprite3D = scene.get("hero")
	var shadow: MeshInstance3D = scene.get("hero_shadow")
	var destination := Vector2i(7, 6)
	_expect(scene.call("select_cell", destination), "delta test destination must be selectable")
	_expect(scene.call("_confirm_move_order"), "delta test route must be accepted")
	var source_hero_position: Vector3 = hero.position
	if check_invalid_deltas:
		var invalid_deltas: Array[float] = [0.0, -0.1, NAN, INF]
		for invalid_delta in invalid_deltas:
			scene.call("_advance_movement", invalid_delta)
			_expect_equal(int(scene.get("movement_state")), MOVEMENT_STATE_MOVING,
				"zero, negative and non-finite delta must leave movement pending")
			_expect(_vector3_is_equal(hero.position, source_hero_position),
				"invalid delta must not mutate visual position")
	for delta in deltas:
		scene.call("_advance_movement", delta)
		_expect_equal(scene.get("actor_coordinate"), destination,
			"delta advancement must not change the already committed logical endpoint")
	var result := {
		"actor": scene.get("actor_coordinate"),
		"state": int(scene.get("movement_state")),
		"hero": hero.position,
		"shadow": shadow.position,
		"accepted_path_empty": (scene.get("accepted_path") as Array[Vector2i]).is_empty(),
		"preview_cleared": scene.get("movement_preview") == null,
		"route_marker_count": grid_view.get_node("RoutePreview").get_child_count(),
	}
	scene.queue_free()
	await process_frame
	return result

func _test_movement_resource_lifecycle() -> void:
	var shadow_scene := MAIN_SCENE.instantiate()
	root.add_child(shadow_scene)
	await process_frame
	shadow_scene.set_process(false)
	var shadow_grid: GridView = shadow_scene.get("grid_view")
	var shadow_hero: Sprite3D = shadow_scene.get("hero")
	var disposable_shadow: MeshInstance3D = shadow_scene.get("hero_shadow")
	var target := Vector2i(7, 6)
	shadow_scene.call("select_cell", target)
	shadow_scene.call("_confirm_move_order")
	disposable_shadow.queue_free()
	await process_frame
	shadow_scene.call("_advance_movement", 0.05)
	_expect_equal(shadow_scene.get("actor_coordinate"), target,
		"shadow loss must not roll back accepted logical destination")
	_expect_equal(int(shadow_scene.get("movement_state")), MOVEMENT_STATE_IDLE,
		"shadow loss must stop animation and return to IDLE")
	_expect(_vector3_is_equal(shadow_hero.position,
		shadow_grid.world_position_for_cell(target) + Vector3(0.0,
			float(shadow_hero.texture.get_height()) * shadow_hero.pixel_size * 0.5, 0.0)),
		"surviving hero must synchronize to the accepted destination")
	_expect_equal(shadow_grid.get_node("RoutePreview").get_child_count(), 0,
		"shadow loss must clear route markers")
	shadow_scene.call("select_cell", Vector2i(6, 6))
	_expect(not shadow_scene.call("_confirm_move_order"),
		"new movement must remain blocked while shadow resource is missing")
	_expect_equal(shadow_scene.get("actor_coordinate"), target,
		"missing-shadow retry must not change logical destination")
	shadow_scene.queue_free()
	await process_frame

	var hero_scene := MAIN_SCENE.instantiate()
	root.add_child(hero_scene)
	await process_frame
	hero_scene.set_process(false)
	var hero_grid: GridView = hero_scene.get("grid_view")
	var surviving_shadow: MeshInstance3D = hero_scene.get("hero_shadow")
	hero_scene.call("select_cell", target)
	hero_scene.call("_confirm_move_order")
	var weak_hero: WeakRef = weakref(hero_scene.get("hero"))
	hero_scene.get("hero").queue_free()
	await process_frame
	hero_scene.call("_advance_movement", 0.05)
	_expect(weak_hero.get_ref() == null, "freed hero fixture must actually release")
	_expect_equal(hero_scene.get("actor_coordinate"), target,
		"hero loss must preserve accepted logical destination")
	_expect_equal(int(hero_scene.get("movement_state")), MOVEMENT_STATE_IDLE,
		"hero loss must stop animation and return to IDLE")
	_expect(_vector3_is_equal(surviving_shadow.position,
		hero_grid.world_position_for_cell(target) + Vector3(0.0, 0.048, 0.0)),
		"surviving shadow must synchronize to accepted destination")
	hero_scene.call("select_cell", Vector2i(6, 6))
	_expect(not hero_scene.call("_confirm_move_order"),
		"new movement must be blocked while hero resource is missing")
	_expect_equal(hero_scene.get("actor_coordinate"), target,
		"missing-hero retry must not mutate logical destination")
	hero_scene.queue_free()
	await process_frame

	var invalid_texture_scene := MAIN_SCENE.instantiate()
	root.add_child(invalid_texture_scene)
	await process_frame
	invalid_texture_scene.set_process(false)
	var invalid_texture_grid: GridView = invalid_texture_scene.get("grid_view")
	var invalid_texture_hero: Sprite3D = invalid_texture_scene.get("hero")
	var invalid_texture_shadow: MeshInstance3D = invalid_texture_scene.get("hero_shadow")
	invalid_texture_scene.call("select_cell", target)
	invalid_texture_scene.call("_confirm_move_order")
	invalid_texture_hero.pixel_size = NAN
	invalid_texture_scene.call("_advance_movement", 0.05)
	_expect_equal(invalid_texture_scene.get("actor_coordinate"), target,
		"invalidated texture scale must preserve accepted destination")
	_expect_equal(int(invalid_texture_scene.get("movement_state")), MOVEMENT_STATE_IDLE,
		"invalidated texture scale must abort presentation")
	_expect(_vector3_is_equal(invalid_texture_shadow.position,
		invalid_texture_grid.world_position_for_cell(target) + Vector3(0.0, 0.048, 0.0)),
		"valid surviving shadow must remain grounded after invalid texture scale")
	invalid_texture_scene.queue_free()
	await process_frame

func _test_scene_release_during_movement() -> void:
	var scene := MAIN_SCENE.instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	scene.call("select_cell", Vector2i(7, 6))
	_expect(scene.call("_confirm_move_order"), "scene-release fixture must begin a valid route")
	var weak_scene: WeakRef = weakref(scene)
	scene.queue_free()
	await process_frame
	_expect(weak_scene.get_ref() == null,
		"scene destroyed during movement must release without a retained callback target")

func _grid_model_snapshot(model: GridModel) -> Dictionary:
	var snapshot: Dictionary = {}
	for z in GridModel.DEPTH:
		for x in GridModel.WIDTH:
			var coordinate := Vector2i(x, z)
			snapshot[coordinate] = [model.height_level_at(coordinate), model.surface_kind_at(coordinate)]
	return snapshot

func _test_grid_view(view: GridView, model: GridModel, initial_selection: Vector2i) -> void:
	var registered_count: int = 0
	var registered_coordinates: Dictionary = {}
	for child in view.get_children():
		var collider := child as StaticBody3D
		if collider == null or not collider.is_in_group("grid_tile"):
			continue
		registered_count += 1
		var coordinate: Vector2i = view.coordinate_from_collider(collider)
		_expect(model.contains(coordinate), "GridView must recognize each collider it created")
		_expect(not registered_coordinates.has(coordinate),
			"GridView must not register duplicate logical cell coordinates")
		registered_coordinates[coordinate] = true
		_expect_equal(coordinate, Vector2i(collider.get_meta("tile_x"), collider.get_meta("tile_z")),
			"registered collider must map back to its logical x/z cell")
	_expect_equal(registered_count, 144, "GridView must build exactly one collider for each of 144 cells")
	_expect_equal(registered_coordinates.size(), 144,
		"GridView must register 144 unique coordinates corresponding to GridModel")
	var selection_overlay := view.get_node("SelectedTile") as MeshInstance3D
	_expect(selection_overlay != null, "GridView must create a selection overlay")
	if selection_overlay != null:
		var expected_initial_position := view.world_position_for_cell(initial_selection) + Vector3(0.0, 0.07, 0.0)
		_expect(_vector3_is_equal(selection_overlay.position, expected_initial_position),
			"GridView must position the initial highlight at the existing selected coordinate")
	_expect(_vector3_is_equal(view.world_position_for_cell(Vector2i(3, 3)), Vector3(3.5, 0.42, 3.5)),
		"GridView must map a height-0 cell to the baseline world position")
	_expect(_vector3_is_equal(view.world_position_for_cell(Vector2i(7, 6)), Vector3(7.5, 1.0, 6.5)),
		"GridView must map a height-1 cell using GridModel")
	_expect(_vector3_is_equal(view.world_position_for_cell(Vector2i(9, 4)), Vector3(9.5, 1.58, 4.5)),
		"GridView must map a height-2 cell using GridModel")
	var grid_overlay := view.get_node("GridOverlay") as MeshInstance3D
	_expect(grid_overlay != null and grid_overlay.visible, "GridView grid overlay must start visible")
	if grid_overlay != null:
		view.set_grid_visible(false)
		_expect(not grid_overlay.visible, "GridView must hide the grid overlay on request")
		view.set_grid_visible(true)
		_expect(grid_overlay.visible, "GridView must restore the grid overlay on request")

func _find_grid_collider(scene: Node, coordinate: Vector2i) -> StaticBody3D:
	for candidate in scene.get_tree().get_nodes_in_group("grid_tile"):
		if candidate.get_meta("tile_x", -1) == coordinate.x \
				and candidate.get_meta("tile_z", -1) == coordinate.y:
			return candidate as StaticBody3D
	return null

func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)

func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [message, expected, actual])

func _vector3_is_equal(actual: Vector3, expected: Vector3) -> bool:
	return actual.distance_to(expected) < 0.0001
