class_name MovementCommandService
extends RefCounted
## Stateless application-layer validation for a provisional movement order.

var _pathfinder: MovementPathfinder

func _init(pathfinder: MovementPathfinder) -> void:
	_pathfinder = pathfinder

func evaluate(
	model: GridModel,
	start: Vector2i,
	destination: Vector2i,
	occupied_coordinates: Array[Vector2i],
	budget: int
) -> MovementCommandResult:
	if model == null:
		return _result(MovementCommandResult.Status.INVALID_MODEL)
	if not model.contains(start):
		return _result(MovementCommandResult.Status.INVALID_START)
	if not model.contains(destination):
		return _result(MovementCommandResult.Status.INVALID_DESTINATION)
	if budget < 0:
		return _result(MovementCommandResult.Status.INVALID_BUDGET)
	if _pathfinder == null:
		return _result(MovementCommandResult.Status.INCONSISTENT_PATHFINDER_RESULT)

	var path_result: MovementPathResult = _pathfinder.find_path(
		model, start, destination, occupied_coordinates
	)
	if path_result == null:
		return _result(MovementCommandResult.Status.INCONSISTENT_PATHFINDER_RESULT)
	if path_result.query_kind != MovementPathResult.QueryKind.PATH:
		return _result(
			MovementCommandResult.Status.INCONSISTENT_PATHFINDER_RESULT,
			[], 0, path_result.status, true
		)
	if path_result.status != MovementPathResult.Status.SUCCESS:
		return _handle_pathfinder_failure(path_result)
	if path_result.path.is_empty() or path_result.path[0] != start \
			or path_result.path[path_result.path.size() - 1] != destination:
		return _result(
			MovementCommandResult.Status.INCONSISTENT_PATHFINDER_RESULT,
			[], 0, path_result.status, true
		)
	if path_result.total_cost < 0:
		return _result(
			MovementCommandResult.Status.INCONSISTENT_PATHFINDER_RESULT,
			[], 0, path_result.status, true
		)

	var verified_path: MovementPathResult = _pathfinder.validate_path_cost(
		model, path_result.path, occupied_coordinates
	)
	if verified_path == null or verified_path.query_kind != MovementPathResult.QueryKind.PATH \
			or verified_path.status != MovementPathResult.Status.SUCCESS \
			or verified_path.path != path_result.path \
			or verified_path.total_cost != path_result.total_cost:
		return _result(
			MovementCommandResult.Status.INCONSISTENT_PATHFINDER_RESULT,
			[], 0, path_result.status, true
		)
	if path_result.total_cost > budget:
		return _result(
			MovementCommandResult.Status.INSUFFICIENT_BUDGET,
			path_result.path, path_result.total_cost, path_result.status, true
		)
	return _result(
		MovementCommandResult.Status.ACCEPTED,
		path_result.path, path_result.total_cost, path_result.status, true
	)

func _handle_pathfinder_failure(path_result: MovementPathResult) -> MovementCommandResult:
	if not path_result.path.is_empty() or path_result.total_cost != 0 \
			or not path_result.costs_by_coordinate.is_empty():
		return _result(
			MovementCommandResult.Status.INCONSISTENT_PATHFINDER_RESULT,
			[], 0, path_result.status, true
		)
	var status: MovementCommandResult.Status
	match path_result.status:
		MovementPathResult.Status.INVALID_START:
			status = MovementCommandResult.Status.INVALID_START
		MovementPathResult.Status.INVALID_DESTINATION:
			status = MovementCommandResult.Status.INVALID_DESTINATION
		MovementPathResult.Status.IMPASSABLE_START:
			status = MovementCommandResult.Status.IMPASSABLE_START
		MovementPathResult.Status.IMPASSABLE_DESTINATION:
			status = MovementCommandResult.Status.ILLEGAL_DESTINATION
		MovementPathResult.Status.DESTINATION_OCCUPIED:
			status = MovementCommandResult.Status.DESTINATION_OCCUPIED
		MovementPathResult.Status.NO_PATH:
			status = MovementCommandResult.Status.NO_PATH
		_:
			status = MovementCommandResult.Status.INCONSISTENT_PATHFINDER_RESULT
	return _result(status, [], 0, path_result.status, true)

func _result(
	status: MovementCommandResult.Status,
	path: Array[Vector2i] = [],
	cost: int = 0,
	pathfinder_status: MovementPathResult.Status = MovementPathResult.Status.SUCCESS,
	has_pathfinder_status: bool = false
) -> MovementCommandResult:
	return MovementCommandResult.new(status, path, cost, pathfinder_status, has_pathfinder_status)
