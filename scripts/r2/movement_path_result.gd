class_name MovementPathResult
extends RefCounted
## Typed output shared by path and reachability queries.

enum Status {
	SUCCESS,
	INVALID_START,
	INVALID_DESTINATION,
	IMPASSABLE_START,
	IMPASSABLE_DESTINATION,
	DESTINATION_OCCUPIED,
	NO_PATH,
	INVALID_BUDGET,
}

var status: Status = Status.SUCCESS
var total_cost: int = 0
var path: Array[Vector2i] = []
var costs_by_coordinate: Dictionary = {}

func _init(
	initial_status: Status = Status.SUCCESS,
	initial_cost: int = 0,
	initial_path: Array[Vector2i] = [],
	initial_costs: Dictionary = {}
) -> void:
	status = initial_status
	total_cost = initial_cost
	path = initial_path.duplicate()
	costs_by_coordinate = initial_costs.duplicate()
