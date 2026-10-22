class_name MovementCommandResult
extends RefCounted
## Logical movement evaluation. Only ACCEPTED results are executable.

enum Status {
	ACCEPTED,
	INVALID_MODEL,
	INVALID_START,
	INVALID_DESTINATION,
	INVALID_BUDGET,
	IMPASSABLE_START,
	ILLEGAL_DESTINATION,
	DESTINATION_OCCUPIED,
	NO_PATH,
	INSUFFICIENT_BUDGET,
	INCONSISTENT_PATHFINDER_RESULT,
}

var status: Status
var has_pathfinder_status: bool = false
var pathfinder_status: MovementPathResult.Status = MovementPathResult.Status.SUCCESS
var path: Array[Vector2i] = []
var total_cost: int = 0

func _init(
	initial_status: Status,
	initial_path: Array[Vector2i] = [],
	initial_cost: int = 0,
	initial_pathfinder_status: MovementPathResult.Status = MovementPathResult.Status.SUCCESS,
	initial_has_pathfinder_status: bool = false
) -> void:
	status = initial_status
	path = initial_path.duplicate()
	total_cost = initial_cost
	pathfinder_status = initial_pathfinder_status
	has_pathfinder_status = initial_has_pathfinder_status

func is_accepted() -> bool:
	return status == Status.ACCEPTED
