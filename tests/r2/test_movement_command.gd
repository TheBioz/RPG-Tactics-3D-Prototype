extends RefCounted
## Logical-only service and path-result integrity tests for R2-05B Checkpoint B.

const GridModelScript = preload("res://scripts/r2/grid_model.gd")
const PathfinderScript = preload("res://scripts/r2/movement_pathfinder.gd")

class StubPathfinder:
	extends MovementPathfinder
	var find_result: MovementPathResult
	var validation_result: MovementPathResult
	var override_validation: bool = false

	func find_path(_model: GridModel, _start: Vector2i, _destination: Vector2i,
		_occupied: Array[Vector2i]) -> MovementPathResult:
		return find_result

	func validate_path_cost(model: GridModel, path: Array[Vector2i],
		occupied: Array[Vector2i]) -> MovementPathResult:
		if override_validation:
			return validation_result
		return super.validate_path_cost(model, path, occupied)

var _checks: int = 0
var _failures: PackedStringArray = []
var _model: GridModel
var _pathfinder: MovementPathfinder
var _service: MovementCommandService

func run() -> Dictionary:
	_model = GridModelScript.new()
	_pathfinder = PathfinderScript.new()
	_service = MovementCommandService.new(_pathfinder)
	_test_accepted_orders()
	_test_rejections_and_pathfinder_reasons()
	_test_malformed_pathfinder_results()
	_test_validation_cost_and_non_mutation()
	_test_repeatability()
	return {"checks": _checks, "failures": _failures}

func _test_accepted_orders() -> void:
	var origin := Vector2i(3, 5)
	var destination := Vector2i(6, 5)
	var accepted := _service.evaluate(_model, origin, destination, [origin], 3)
	_expect_equal(accepted.status, MovementCommandResult.Status.ACCEPTED,
		"legal path at exact movement budget must be accepted")
	_expect(accepted.is_accepted(), "accepted result must expose positive execution permission")
	_expect_equal(accepted.path, [origin, Vector2i(4, 5), Vector2i(5, 5), destination],
		"accepted result must copy the deterministic shortest path")
	_expect_equal(accepted.total_cost, 3, "accepted result must expose exact path cost")
	_expect(accepted.has_pathfinder_status
		and accepted.pathfinder_status == MovementPathResult.Status.SUCCESS,
		"accepted result must retain the pathfinder success status")

	var same_cell := _service.evaluate(_model, origin, origin, [origin], 0)
	_expect_equal(same_cell.status, MovementCommandResult.Status.ACCEPTED,
		"origin-equals-destination must be accepted as a no-op")
	_expect_equal(same_cell.path, [origin], "same-cell order must contain its origin")
	_expect_equal(same_cell.total_cost, 0, "same-cell order must cost zero")

	var too_expensive := _service.evaluate(_model, Vector2i(6, 6), Vector2i(7, 6), [], 1)
	_expect_equal(too_expensive.status, MovementCommandResult.Status.INSUFFICIENT_BUDGET,
		"one-level ascent must be rejected when its cost exceeds budget")
	_expect(not too_expensive.is_accepted(), "insufficient-budget route must never be executable")
	_expect_equal(too_expensive.path, [Vector2i(6, 6), Vector2i(7, 6)],
		"insufficient-budget result may retain a diagnostic route")
	_expect_equal(too_expensive.total_cost, 2,
		"insufficient-budget result must retain the diagnostic cost")

func _test_rejections_and_pathfinder_reasons() -> void:
	_expect_equal(_service.evaluate(null, Vector2i.ZERO, Vector2i.ONE, [], 4).status,
		MovementCommandResult.Status.INVALID_MODEL, "null model must be rejected")
	_expect_equal(_service.evaluate(_model, Vector2i(-1, 0), Vector2i.ONE, [], 4).status,
		MovementCommandResult.Status.INVALID_START, "out-of-bounds origin must be rejected")
	_expect_equal(_service.evaluate(_model, Vector2i(3, 5), Vector2i(12, 5), [], 4).status,
		MovementCommandResult.Status.INVALID_DESTINATION, "out-of-bounds destination must be rejected")
	_expect_equal(_service.evaluate(_model, Vector2i(3, 5), Vector2i(4, 5), [], -1).status,
		MovementCommandResult.Status.INVALID_BUDGET, "negative budget must be rejected")

	var occupied := _service.evaluate(_model, Vector2i(3, 5), Vector2i(4, 5), [Vector2i(4, 5)], 4)
	_expect_equal(occupied.status, MovementCommandResult.Status.DESTINATION_OCCUPIED,
		"occupied destination must be distinguished")
	_expect_equal(occupied.pathfinder_status, MovementPathResult.Status.DESTINATION_OCCUPIED,
		"occupied rejection must retain pathfinder reason")
	var water := _service.evaluate(_model, Vector2i(3, 2), Vector2i(2, 2), [], 4)
	_expect_equal(water.status, MovementCommandResult.Status.ILLEGAL_DESTINATION,
		"water destination must be distinguished as illegal")
	_expect_equal(water.pathfinder_status, MovementPathResult.Status.IMPASSABLE_DESTINATION,
		"illegal destination must retain pathfinder reason")
	var no_path := _service.evaluate(_model, Vector2i(3, 5), Vector2i(5, 5),
		[Vector2i(4, 5), Vector2i(3, 4), Vector2i(3, 6), Vector2i(2, 5)], 4)
	_expect_equal(no_path.status, MovementCommandResult.Status.NO_PATH,
		"blocked route must report no path")
	_expect_equal(no_path.pathfinder_status, MovementPathResult.Status.NO_PATH,
		"no-route rejection must retain pathfinder reason")
	var bad_start := _service.evaluate(_model, Vector2i(0, 0), Vector2i(3, 3), [], 4)
	_expect_equal(bad_start.status, MovementCommandResult.Status.IMPASSABLE_START,
		"water origin must be distinguished")
	var stone_and_height := _service.evaluate(_model, Vector2i(7, 5), Vector2i(7, 4), [], 2)
	_expect_equal(stone_and_height.status, MovementCommandResult.Status.ACCEPTED,
		"stone entry cost must be preserved")
	_expect_equal(stone_and_height.total_cost, 2,
		"same-height stone route must cost exactly two")

func _test_malformed_pathfinder_results() -> void:
	var origin := Vector2i(3, 5)
	var destination := Vector2i(5, 5)
	var wrong_kind := _stub_result(MovementPathResult.new(
		MovementPathResult.QueryKind.REACHABILITY, MovementPathResult.Status.SUCCESS, 2,
		[origin, Vector2i(4, 5), destination]
	))
	_expect_inconsistent(wrong_kind, origin, destination, "wrong query kind")
	_expect_inconsistent(_stub_result(null), origin, destination, "null pathfinder response")

	var wrong_first: Array[Vector2i] = [Vector2i(4, 5), destination]
	_expect_inconsistent(_stub_result(MovementPathResult.new(
		MovementPathResult.QueryKind.PATH, MovementPathResult.Status.SUCCESS, 1, wrong_first
	)), origin, destination, "wrong first endpoint")
	var diagonal: Array[Vector2i] = [origin, Vector2i(4, 4), destination]
	_expect_inconsistent(_stub_result(MovementPathResult.new(
		MovementPathResult.QueryKind.PATH, MovementPathResult.Status.SUCCESS, 2, diagonal
	)), origin, destination, "diagonal step")
	var repeated: Array[Vector2i] = [origin, Vector2i(4, 5), Vector2i(4, 5), destination]
	_expect_inconsistent(_stub_result(MovementPathResult.new(
		MovementPathResult.QueryKind.PATH, MovementPathResult.Status.SUCCESS, 3, repeated
	)), origin, destination, "repeated coordinate")
	var wrong_last: Array[Vector2i] = [origin, Vector2i(4, 5), Vector2i(4, 6)]
	_expect_inconsistent(_stub_result(MovementPathResult.new(
		MovementPathResult.QueryKind.PATH, MovementPathResult.Status.SUCCESS, 2, wrong_last
	)), origin, destination, "wrong last endpoint")

	var mismatched_cost := _stub_result(MovementPathResult.new(
		MovementPathResult.QueryKind.PATH, MovementPathResult.Status.SUCCESS, 99,
		[origin, Vector2i(4, 5), destination]
	))
	_expect_inconsistent(mismatched_cost, origin, destination, "reported cost differs from validated cost")
	var negative_cost := _stub_result(MovementPathResult.new(
		MovementPathResult.QueryKind.PATH, MovementPathResult.Status.SUCCESS, -1,
		[origin, Vector2i(4, 5), destination]
	))
	_expect_inconsistent(negative_cost, origin, destination, "negative reported cost")

	var invalid_validation := _stub_result(MovementPathResult.new(
		MovementPathResult.QueryKind.PATH, MovementPathResult.Status.SUCCESS, 2,
		[origin, Vector2i(4, 5), destination]
	), MovementPathResult.new(
		MovementPathResult.QueryKind.PATH, MovementPathResult.Status.INVALID_PATH
	))
	_expect_inconsistent(invalid_validation, origin, destination, "validator rejects successful route")
	var failure_with_partial_path := _stub_result(MovementPathResult.new(
		MovementPathResult.QueryKind.PATH, MovementPathResult.Status.NO_PATH, 1,
		[origin, destination]
	))
	_expect_inconsistent(failure_with_partial_path, origin, destination,
		"pathfinder failure improperly carries partial route")

func _test_validation_cost_and_non_mutation() -> void:
	var origin := Vector2i(6, 6)
	var destination := Vector2i(7, 6)
	var path: Array[Vector2i] = [origin, destination]
	var occupied: Array[Vector2i] = [origin]
	var model_before := _snapshot_model(_model)
	var occupied_before := occupied.duplicate()
	var validation := _pathfinder.validate_path_cost(_model, path, occupied)
	_expect_equal(validation.status, MovementPathResult.Status.SUCCESS,
		"valid constructed ascent route must pass independent path validation")
	_expect_equal(validation.total_cost, 2, "path validator must calculate ascent cost")
	var command := _service.evaluate(_model, origin, destination, occupied, 2)
	_expect_equal(command.status, MovementCommandResult.Status.ACCEPTED,
		"validated route must be accepted at exact budget")
	_expect_equal(_snapshot_model(_model), model_before, "service must not mutate GridModel")
	_expect_equal(occupied, occupied_before, "service must not mutate occupancy input")

	var unavailable := _service.evaluate(_model, Vector2i(3, 5), Vector2i(5, 5),
		[Vector2i(4, 5), Vector2i(3, 4), Vector2i(3, 6), Vector2i(2, 5)], 4)
	_expect(not unavailable.is_accepted(), "failed route validation must not accept a command")
	_expect_equal(_snapshot_model(_model), model_before, "failed service evaluation must not mutate model")

func _test_repeatability() -> void:
	var expected_path: Array[Vector2i] = [Vector2i(3, 5), Vector2i(4, 5), Vector2i(5, 5)]
	for _attempt in 5:
		var result := _service.evaluate(_model, Vector2i(3, 5), Vector2i(5, 5), [], 4)
		_expect_equal(result.status, MovementCommandResult.Status.ACCEPTED,
			"repeated same-input evaluation must stay accepted")
		_expect_equal(result.path, expected_path,
			"repeated same-input evaluation must return the same route")
		_expect_equal(result.total_cost, 2,
			"repeated same-input evaluation must return the same cost")

func _stub_result(find_result: MovementPathResult,
	validation_result: MovementPathResult = null) -> MovementCommandService:
	var stub := StubPathfinder.new()
	stub.find_result = find_result
	if validation_result != null:
		stub.override_validation = true
		stub.validation_result = validation_result
	return MovementCommandService.new(stub)

func _expect_inconsistent(service: MovementCommandService, start: Vector2i,
	destination: Vector2i, message: String) -> void:
	var result := service.evaluate(_model, start, destination, [], 10)
	_expect_equal(result.status, MovementCommandResult.Status.INCONSISTENT_PATHFINDER_RESULT,
		message + " must be rejected as inconsistent")
	_expect(not result.is_accepted(), message + " must not be executable")
	_expect(result.path.is_empty() and result.total_cost == 0,
		message + " must not expose inconsistent route data")

func _snapshot_model(model: GridModel) -> Dictionary:
	var snapshot: Dictionary = {}
	for z in GridModel.DEPTH:
		for x in GridModel.WIDTH:
			var coordinate := Vector2i(x, z)
			snapshot[coordinate] = [model.height_level_at(coordinate), model.surface_kind_at(coordinate)]
	return snapshot

func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)

func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [message, expected, actual])
