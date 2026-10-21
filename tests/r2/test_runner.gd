extends SceneTree
## Minimal dependency-free test runner for the R2 logical grid model.

const GridModelScript = preload("res://scripts/r2/grid_model.gd")
const MAIN_SCENE: PackedScene = preload("res://scenes/IsometricArtTest.tscn")

const CELL_SIZE: float = 1.0
const STEP_Y: float = 0.58
const BASE_Y: float = 0.42

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
	await _test_scene_interactions()
	if _failures.is_empty():
		print("R2-B1-B grid/scene: %d checks passed" % _checks)
		quit(0)
		return
	for failure in _failures:
		push_error("R2-B1-B: " + failure)
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

func _test_scene_interactions() -> void:
	var scene := MAIN_SCENE.instantiate()
	root.add_child(scene)
	await process_frame

	var model: GridModel = scene.get("grid_model")
	var grid_view: GridView = scene.get("grid_view")
	var hero: Sprite3D = scene.get("hero")
	var shadow: MeshInstance3D = scene.get("hero_shadow")
	_test_grid_view(grid_view, model)
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

	var selected_before_invalid: Vector2i = scene.get("selected_coordinate")
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
	_expect(not scene.call("select_cell", Vector2i(12, 12)), "out-of-bounds cell must not be selectable")
	_expect_equal(scene.get("selected_coordinate"), selected_before_invalid_cell,
		"invalid cell selection must not mutate selection")
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

func _test_grid_view(view: GridView, model: GridModel) -> void:
	var registered_count: int = 0
	for child in view.get_children():
		var collider := child as StaticBody3D
		if collider == null or not collider.is_in_group("grid_tile"):
			continue
		registered_count += 1
		var coordinate: Vector2i = view.coordinate_from_collider(collider)
		_expect(model.contains(coordinate), "GridView must recognize each collider it created")
		_expect_equal(coordinate, Vector2i(collider.get_meta("tile_x"), collider.get_meta("tile_z")),
			"registered collider must map back to its logical x/z cell")
	_expect_equal(registered_count, 144, "GridView must build exactly one collider for each of 144 cells")
	_expect(_vector3_is_equal(view.world_position_for_cell(Vector2i(3, 3)), Vector3(3.5, 0.42, 3.5)),
		"GridView must map a height-0 cell to the baseline world position")
	_expect(_vector3_is_equal(view.world_position_for_cell(Vector2i(7, 6)), Vector3(7.5, 1.0, 6.5)),
		"GridView must map a height-1 cell using GridModel")
	_expect(_vector3_is_equal(view.world_position_for_cell(Vector2i(9, 4)), Vector3(9.5, 1.58, 4.5)),
		"GridView must map a height-2 cell using GridModel")

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
