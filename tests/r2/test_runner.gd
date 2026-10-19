extends SceneTree
## Minimal dependency-free test runner for the R2 logical grid model.

const GridModelScript = preload("res://scripts/r2/grid_model.gd")

var _failures: PackedStringArray = []
var _checks: int = 0

func _initialize() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	_test_refcounted_model_and_cell_count()
	_test_bounds_and_invalid_results()
	_test_baseline_heights()
	_test_baseline_surfaces()
	if _failures.is_empty():
		print("R2-B1 GridModel: %d checks passed" % _checks)
		quit(0)
		return
	for failure in _failures:
		push_error("R2-B1 GridModel: " + failure)
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
		Vector2i(-1, 0), Vector2i(0, -1), Vector2i(12, 0), Vector2i(0, 12),
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
	_expect_equal(model.height_level_at(Vector2i(7, 6)), 1, "baseline sample must remain height 1")
	_expect_equal(model.height_level_at(Vector2i(9, 4)), 2, "baseline sample must remain height 2")

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

func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)

func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [message, expected, actual])
