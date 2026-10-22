class_name MovementPathfinder
extends RefCounted
## Deterministic Dijkstra queries over GridModel; no scene, physics or render dependencies.

const NEIGHBOR_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
]

func find_path(
	model: GridModel,
	start: Vector2i,
	destination: Vector2i,
	occupied_coordinates: Array[Vector2i]
) -> MovementPathResult:
	if model == null or not model.contains(start):
		return MovementPathResult.new(MovementPathResult.Status.INVALID_START)
	if not model.contains(destination):
		return MovementPathResult.new(MovementPathResult.Status.INVALID_DESTINATION)
	if _is_water(model, start):
		return MovementPathResult.new(MovementPathResult.Status.IMPASSABLE_START)
	if _is_water(model, destination):
		return MovementPathResult.new(MovementPathResult.Status.IMPASSABLE_DESTINATION)
	var occupied := _make_occupancy_set(occupied_coordinates)
	if destination != start and occupied.has(destination):
		return MovementPathResult.new(MovementPathResult.Status.DESTINATION_OCCUPIED)

	var search := _dijkstra(model, start, occupied)
	var distances: Dictionary = search["distances"]
	if not distances.has(destination):
		return MovementPathResult.new(MovementPathResult.Status.NO_PATH)
	var path := _reconstruct_path(start, destination, search["predecessors"])
	if path.is_empty():
		return MovementPathResult.new(MovementPathResult.Status.NO_PATH)
	return MovementPathResult.new(MovementPathResult.Status.SUCCESS, distances[destination], path)

func reachable_cells(
	model: GridModel,
	start: Vector2i,
	occupied_coordinates: Array[Vector2i],
	budget: int
) -> MovementPathResult:
	if budget < 0:
		return MovementPathResult.new(MovementPathResult.Status.INVALID_BUDGET)
	if model == null or not model.contains(start):
		return MovementPathResult.new(MovementPathResult.Status.INVALID_START)
	if _is_water(model, start):
		return MovementPathResult.new(MovementPathResult.Status.IMPASSABLE_START)
	var occupied := _make_occupancy_set(occupied_coordinates)
	var distances: Dictionary = _dijkstra(model, start, occupied)["distances"]
	var affordable_costs: Dictionary = {}
	for coordinate in distances:
		var cost: int = distances[coordinate]
		if cost <= budget:
			affordable_costs[coordinate] = cost
	return MovementPathResult.new(MovementPathResult.Status.SUCCESS, 0, [], affordable_costs)

func _dijkstra(model: GridModel, start: Vector2i, occupied: Dictionary) -> Dictionary:
	var distances: Dictionary = {start: 0}
	var predecessors: Dictionary = {}
	var pending: Array[Vector2i] = [start]
	var pending_members: Dictionary = {start: true}
	var settled: Dictionary = {}
	while not pending.is_empty():
		var current := _take_lowest_pending(pending, pending_members, distances)
		if settled.has(current):
			continue
		settled[current] = true
		for offset in NEIGHBOR_OFFSETS:
			var neighbor: Vector2i = current + offset
			if not model.contains(neighbor) or _is_water(model, neighbor):
				continue
			if occupied.has(neighbor) and neighbor != start:
				continue
			var height_delta: int = model.height_level_at(neighbor) - model.height_level_at(current)
			if absi(height_delta) > 1:
				continue
			var step_cost: int = _entry_cost(model, neighbor) + maxi(height_delta, 0)
			var candidate_cost: int = distances[current] + step_cost
			if not distances.has(neighbor) or candidate_cost < int(distances[neighbor]):
				distances[neighbor] = candidate_cost
				predecessors[neighbor] = current
				if not pending_members.has(neighbor):
					pending.append(neighbor)
					pending_members[neighbor] = true
	return {"distances": distances, "predecessors": predecessors}

func _take_lowest_pending(
	pending: Array[Vector2i],
	pending_members: Dictionary,
	distances: Dictionary
) -> Vector2i:
	var best_index: int = 0
	for index in range(1, pending.size()):
		var candidate: Vector2i = pending[index]
		var best: Vector2i = pending[best_index]
		var candidate_cost: int = distances[candidate]
		var best_cost: int = distances[best]
		if candidate_cost < best_cost or (candidate_cost == best_cost and _coordinate_precedes(candidate, best)):
			best_index = index
	var selected: Vector2i = pending[best_index]
	pending.remove_at(best_index)
	pending_members.erase(selected)
	return selected

func _coordinate_precedes(left: Vector2i, right: Vector2i) -> bool:
	return left.x < right.x or (left.x == right.x and left.y < right.y)

func _reconstruct_path(start: Vector2i, destination: Vector2i, predecessors: Dictionary) -> Array[Vector2i]:
	var reversed_path: Array[Vector2i] = [destination]
	var current: Vector2i = destination
	while current != start:
		if not predecessors.has(current):
			return []
		current = predecessors[current]
		reversed_path.append(current)
	reversed_path.reverse()
	return reversed_path

func _entry_cost(model: GridModel, coordinate: Vector2i) -> int:
	var surface: int = model.surface_kind_at(coordinate)
	return 2 if surface == GridModel.SurfaceKind.STONE else 1

func _is_water(model: GridModel, coordinate: Vector2i) -> bool:
	return model.surface_kind_at(coordinate) == GridModel.SurfaceKind.WATER

func _make_occupancy_set(occupied_coordinates: Array[Vector2i]) -> Dictionary:
	var occupied: Dictionary = {}
	for coordinate in occupied_coordinates:
		occupied[coordinate] = true
	return occupied
