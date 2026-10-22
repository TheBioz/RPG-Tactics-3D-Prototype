class_name MovementPathResult
extends RefCounted
## Typed output for path and reachability queries.

enum QueryKind {
	PATH,
	REACHABILITY,
}

enum Status {
	SUCCESS,
	INVALID_START,
	INVALID_DESTINATION,
	IMPASSABLE_START,
	IMPASSABLE_DESTINATION,
	DESTINATION_OCCUPIED,
	NO_PATH,
	INVALID_BUDGET,
	INVALID_PATH,
}

## PATH uses status, total_cost and path; REACHABILITY uses status and costs_by_coordinate.
## Failure results always carry empty path/cost maps and zero total cost.
var query_kind: QueryKind
var status: Status
var total_cost: int = 0
var path: Array[Vector2i] = []
var costs_by_coordinate: Dictionary = {}

func _init(
	initial_query_kind: QueryKind,
	initial_status: Status,
	initial_cost: int = 0,
	initial_path: Array[Vector2i] = [],
	initial_costs: Dictionary = {}
) -> void:
	query_kind = initial_query_kind
	status = initial_status
	total_cost = initial_cost
	path = initial_path.duplicate()
	costs_by_coordinate = initial_costs.duplicate()
