extends RefCounted
## Focused, data-oriented tests for the R2-05A logical pathfinder.

const GridModelScript = preload("res://scripts/r2/grid_model.gd")
const PathfinderScript = preload("res://scripts/r2/movement_pathfinder.gd")

class SyntheticGridModel:
	extends GridModel
	var fixture_width: int = 0
	var fixture_depth: int = 0
	var fixture_heights: Dictionary = {}
	var fixture_surfaces: Dictionary = {}

	func configure_fixture(width: int, depth: int) -> void:
		fixture_width = width
		fixture_depth = depth

	func set_fixture_cell(coordinate: Vector2i, height: int, surface: int) -> void:
		fixture_heights[coordinate] = height
		fixture_surfaces[coordinate] = surface

	func contains(coordinate: Vector2i) -> bool:
		return coordinate.x >= 0 and coordinate.x < fixture_width \
			and coordinate.y >= 0 and coordinate.y < fixture_depth

	func height_level_at(coordinate: Vector2i) -> int:
		return int(fixture_heights.get(coordinate, GridModel.INVALID_HEIGHT))

	func surface_kind_at(coordinate: Vector2i) -> int:
		return int(fixture_surfaces.get(coordinate, GridModel.INVALID_SURFACE))

var _checks: int = 0
var _failures: PackedStringArray = []
var _pathfinder: MovementPathfinder
var _model: GridModel

func run() -> Dictionary:
	_pathfinder = PathfinderScript.new()
	_model = GridModelScript.new()
	_test_real_map_routes_and_costs()
	_test_validation_and_occupancy()
	_test_determinism_and_non_mutation()
	_test_reachability_budgets()
	_test_synthetic_disconnection_and_cost_alternative()
	return {"checks": _checks, "failures": _failures}

func _test_real_map_routes_and_costs() -> void:
	var same := _pathfinder.find_path(_model, Vector2i(3, 3), Vector2i(3, 3), [])
	_expect_equal(same.status, MovementPathResult.Status.SUCCESS, "valid same-cell route must succeed")
	_expect_equal(same.total_cost, 0, "same-cell route must cost zero")
	_expect_equal(same.path, [Vector2i(3, 3)], "same-cell route must contain only its origin")

	var horizontal := _pathfinder.find_path(_model, Vector2i(3, 5), Vector2i(6, 5), [])
	_expect_route(horizontal, [Vector2i(3, 5), Vector2i(4, 5), Vector2i(5, 5), Vector2i(6, 5)], 3,
		"horizontal road route must use orthogonal unit-cost steps")
	var vertical := _pathfinder.find_path(_model, Vector2i(4, 4), Vector2i(4, 7), [])
	_expect_route(vertical, [Vector2i(4, 4), Vector2i(4, 5), Vector2i(4, 6), Vector2i(4, 7)], 3,
		"vertical route must accumulate entry costs")

	var uphill := _pathfinder.find_path(_model, Vector2i(6, 6), Vector2i(7, 6), [])
	_expect_route(uphill, [Vector2i(6, 6), Vector2i(7, 6)], 2,
		"one-level ascent must add one to the destination entry cost")
	var downhill := _pathfinder.find_path(_model, Vector2i(7, 6), Vector2i(6, 6), [])
	_expect_route(downhill, [Vector2i(7, 6), Vector2i(6, 6)], 1,
		"one-level descent must have no extra cost")
	var stone := _pathfinder.find_path(_model, Vector2i(7, 5), Vector2i(7, 4), [])
	_expect_route(stone, [Vector2i(7, 5), Vector2i(7, 4)], 2,
		"entering same-height stone must cost two")
	var grass_b := _pathfinder.find_path(_model, Vector2i(2, 3), Vector2i(3, 3), [])
	_expect_equal(_model.surface_kind_at(Vector2i(3, 3)), GridModel.SurfaceKind.GRASS_B,
		"GRASS_B test destination must use the real map surface")
	_expect_route(grass_b, [Vector2i(2, 3), Vector2i(3, 3)], 1,
		"GRASS_B must be traversable at cost one")

func _test_validation_and_occupancy() -> void:
	var invalid_start := _pathfinder.find_path(_model, Vector2i(-1, 2), Vector2i(3, 3), [])
	_expect_equal(invalid_start.status, MovementPathResult.Status.INVALID_START,
		"out-of-bounds origin must have an explicit failure status")
	var invalid_destination := _pathfinder.find_path(_model, Vector2i(3, 3), Vector2i(12, 3), [])
	_expect_equal(invalid_destination.status, MovementPathResult.Status.INVALID_DESTINATION,
		"out-of-bounds destination must have an explicit failure status")
	var water_start := _pathfinder.find_path(_model, Vector2i(0, 0), Vector2i(3, 3), [])
	_expect_equal(water_start.status, MovementPathResult.Status.IMPASSABLE_START,
		"water origin must be rejected")
	var water_destination := _pathfinder.find_path(_model, Vector2i(3, 2), Vector2i(2, 2), [])
	_expect_equal(water_destination.status, MovementPathResult.Status.IMPASSABLE_DESTINATION,
		"water destination must be rejected")

	var occupied_destination := _pathfinder.find_path(_model, Vector2i(3, 5), Vector2i(5, 5), [Vector2i(5, 5)])
	_expect_equal(occupied_destination.status, MovementPathResult.Status.DESTINATION_OCCUPIED,
		"occupied destination must have an explicit failure status")
	var occupied_middle := _pathfinder.find_path(_model, Vector2i(3, 5), Vector2i(5, 5), [Vector2i(4, 5)])
	_expect_equal(occupied_middle.status, MovementPathResult.Status.SUCCESS,
		"path may detour around an occupied intermediate cell")
	_expect(not occupied_middle.path.has(Vector2i(4, 5)), "route must not traverse occupied intermediate cell")
	var occupied_start: Array[Vector2i] = [Vector2i(3, 5)]
	var from_occupied_start := _pathfinder.find_path(_model, Vector2i(3, 5), Vector2i(5, 5), occupied_start)
	_expect_equal(from_occupied_start.status, MovementPathResult.Status.SUCCESS,
		"occupied origin must still be allowed as the actor's own starting cell")
	_expect_equal(occupied_start, [Vector2i(3, 5)], "pathfinder must not mutate the occupancy input")

	var water_fixture := _new_fixture(4, 3)
	water_fixture.set_fixture_cell(Vector2i(1, 1), 0, GridModel.SurfaceKind.WATER)
	var blocked_by_water := _pathfinder.find_path(water_fixture, Vector2i(0, 1), Vector2i(2, 1),
		[Vector2i(0, 0), Vector2i(0, 2), Vector2i(1, 0), Vector2i(1, 2), Vector2i(2, 0), Vector2i(2, 2)])
	_expect_equal(blocked_by_water.status, MovementPathResult.Status.NO_PATH,
		"water cannot be used as a route intermediate when detours are occupied")

	var cliff_fixture := _new_fixture(2, 1)
	cliff_fixture.set_fixture_cell(Vector2i(1, 0), 2, GridModel.SurfaceKind.GRASS)
	var cliff := _pathfinder.find_path(cliff_fixture, Vector2i(0, 0), Vector2i(1, 0), [])
	_expect_equal(cliff.status, MovementPathResult.Status.NO_PATH,
		"adjacent two-level height discontinuity must block movement")

	var corner_fixture := _new_fixture(2, 2)
	var corner := _pathfinder.find_path(corner_fixture, Vector2i(0, 0), Vector2i(1, 1),
		[Vector2i(1, 0), Vector2i(0, 1)])
	_expect_equal(corner.status, MovementPathResult.Status.NO_PATH,
		"diagonal movement must not cut a blocked orthogonal corner")

func _test_determinism_and_non_mutation() -> void:
	var occupied: Array[Vector2i] = [Vector2i(9, 6), Vector2i(2, 2)]
	var occupancy_before := occupied.duplicate()
	var model_before := _snapshot_model(_model)
	var expected_tie: Array[Vector2i] = [Vector2i(4, 5), Vector2i(4, 6), Vector2i(5, 6)]
	for _attempt in 5:
		var result := _pathfinder.find_path(_model, Vector2i(4, 5), Vector2i(5, 6), [])
		_expect_equal(result.status, MovementPathResult.Status.SUCCESS, "equal-cost route must succeed")
		_expect_equal(result.path, expected_tie,
			"equal-cost route must follow documented X/Z frontier tie-break")
		_expect_equal(result.total_cost, 2, "tie route must report the sum of two entry costs")
		_expect(_path_is_orthogonal_and_unique(result.path),
			"positive-cost shortest path must not contain loops or duplicate cells")
		_expect_equal(_route_cost(_model, result.path), result.total_cost,
			"reported path cost must equal independently summed step costs")
	var route := _pathfinder.find_path(_model, Vector2i(3, 5), Vector2i(6, 5), occupied)
	_expect_equal(route.status, MovementPathResult.Status.SUCCESS, "query with unrelated occupancy must succeed")
	_expect_equal(occupied, occupancy_before, "path query must leave occupancy byte-for-byte equivalent")
	_expect_equal(_snapshot_model(_model), model_before, "path queries must not mutate GridModel data")

func _test_reachability_budgets() -> void:
	var start := Vector2i(3, 5)
	var zero := _pathfinder.reachable_cells(_model, start, [], 0)
	_expect_equal(zero.status, MovementPathResult.Status.SUCCESS, "zero budget must be accepted")
	_expect_equal(zero.costs_by_coordinate, {start: 0}, "zero budget must reach only the valid origin")
	var insufficient := _pathfinder.reachable_cells(_model, start, [], 1)
	_expect_equal(insufficient.costs_by_coordinate.get(Vector2i(5, 5), -1), -1,
		"insufficient budget must exclude a two-step destination")
	var exact := _pathfinder.reachable_cells(_model, start, [], 2)
	_expect_equal(exact.costs_by_coordinate.get(Vector2i(5, 5), -1), 2,
		"exact budget must include a destination at that minimum cost")
	var broad := _pathfinder.reachable_cells(_model, start, [], 6)
	_expect_equal(broad.costs_by_coordinate.get(Vector2i(7, 6), -1), 6,
		"reachable costs must include terrain and ascent costs")
	for coordinate in broad.costs_by_coordinate:
		_expect(int(broad.costs_by_coordinate[coordinate]) <= 6,
			"reachable set must not contain cells above the movement budget")
	var negative := _pathfinder.reachable_cells(_model, start, [], -1)
	_expect_equal(negative.status, MovementPathResult.Status.INVALID_BUDGET,
		"negative movement budget must be rejected explicitly")
	var occupied := _pathfinder.reachable_cells(_model, start, [Vector2i(4, 5)], 4)
	_expect(not occupied.costs_by_coordinate.has(Vector2i(4, 5)),
		"occupied cell must not be reachable")
	_expect(occupied.costs_by_coordinate.has(Vector2i(5, 5)),
		"cells beyond occupancy may remain reachable through a legal detour")
	var with_water := _pathfinder.reachable_cells(_model, Vector2i(3, 2), [], 4)
	_expect(not with_water.costs_by_coordinate.has(Vector2i(2, 2)),
		"water must not appear in reachable cells")
	var invalid_origin := _pathfinder.reachable_cells(_model, Vector2i(12, 0), [], 3)
	_expect_equal(invalid_origin.status, MovementPathResult.Status.INVALID_START,
		"reachability must reject out-of-bounds origin")
	var water_origin := _pathfinder.reachable_cells(_model, Vector2i(0, 0), [], 3)
	_expect_equal(water_origin.status, MovementPathResult.Status.IMPASSABLE_START,
		"reachability must reject water origin")

func _test_synthetic_disconnection_and_cost_alternative() -> void:
	var cost_fixture := _new_fixture(5, 2)
	for x in range(1, 4):
		cost_fixture.set_fixture_cell(Vector2i(x, 1), 0, GridModel.SurfaceKind.STONE)
	var cheaper_detour := _pathfinder.find_path(cost_fixture, Vector2i(0, 1), Vector2i(4, 1), [])
	_expect_equal(cheaper_detour.status, MovementPathResult.Status.SUCCESS,
		"synthetic weighted fixture must have a legal detour")
	_expect_equal(cheaper_detour.path.size(), 7,
		"Dijkstra must choose the six-step grass detour over four expensive steps")
	_expect_equal(cheaper_detour.total_cost, 6,
		"longer grass detour must beat the direct stone route cost of seven")
	_expect_equal(_route_cost(cost_fixture, cheaper_detour.path), cheaper_detour.total_cost,
		"synthetic route cost must reconstruct from independently summed entries")

func _new_fixture(width: int, depth: int) -> SyntheticGridModel:
	var fixture := SyntheticGridModel.new()
	fixture.configure_fixture(width, depth)
	for z in depth:
		for x in width:
			fixture.set_fixture_cell(Vector2i(x, z), 0, GridModel.SurfaceKind.GRASS)
	return fixture

func _snapshot_model(model: GridModel) -> Dictionary:
	var values: Dictionary = {}
	for z in GridModel.DEPTH:
		for x in GridModel.WIDTH:
			var coordinate := Vector2i(x, z)
			values[coordinate] = [model.height_level_at(coordinate), model.surface_kind_at(coordinate)]
	return values

func _route_cost(model: GridModel, route: Array[Vector2i]) -> int:
	var total := 0
	for index in range(1, route.size()):
		var previous: Vector2i = route[index - 1]
		var current: Vector2i = route[index]
		var entry_cost := 2 if model.surface_kind_at(current) == GridModel.SurfaceKind.STONE else 1
		total += entry_cost + maxi(model.height_level_at(current) - model.height_level_at(previous), 0)
	return total

func _path_is_orthogonal_and_unique(route: Array[Vector2i]) -> bool:
	var visited: Dictionary = {}
	for index in route.size():
		var coordinate: Vector2i = route[index]
		if visited.has(coordinate):
			return false
		visited[coordinate] = true
		if index > 0 and absi(coordinate.x - route[index - 1].x) + absi(coordinate.y - route[index - 1].y) != 1:
			return false
	return true

func _expect_route(result: MovementPathResult, expected_path: Array[Vector2i], expected_cost: int, message: String) -> void:
	_expect_equal(result.status, MovementPathResult.Status.SUCCESS, message + " status")
	_expect_equal(result.path, expected_path, message + " path")
	_expect_equal(result.total_cost, expected_cost, message + " cost")

func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)

func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [message, expected, actual])
