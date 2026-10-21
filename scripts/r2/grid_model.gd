class_name GridModel
extends RefCounted
## Logical data for the small R2 art-test grid. Coordinates are Vector2i(x, z).
## This model has no dependency on scene nodes or rendered resources.

enum SurfaceKind {
	GRASS = 0,
	GRASS_B = 1,
	ROAD = 2,
	STONE = 3,
	WATER = 4,
}

const WIDTH: int = 12
const DEPTH: int = 12
const INVALID_HEIGHT: int = -1
const INVALID_SURFACE: int = -1

var _height_rows: Array[PackedInt32Array] = []
var _surface_rows: Array[PackedInt32Array] = []

func _init() -> void:
	_build_baseline_cells()

func contains(coordinate: Vector2i) -> bool:
	return coordinate.x >= 0 and coordinate.x < WIDTH \
		and coordinate.y >= 0 and coordinate.y < DEPTH

func height_level_at(coordinate: Vector2i) -> int:
	if not contains(coordinate):
		return INVALID_HEIGHT
	return _height_rows[coordinate.y][coordinate.x]

func surface_kind_at(coordinate: Vector2i) -> int:
	if not contains(coordinate):
		return INVALID_SURFACE
	return _surface_rows[coordinate.y][coordinate.x]

func _build_baseline_cells() -> void:
	for z in range(DEPTH):
		var height_row := PackedInt32Array()
		var surface_row := PackedInt32Array()
		height_row.resize(WIDTH)
		surface_row.resize(WIDTH)
		for x in range(WIDTH):
			var level: int = 0
			if x >= 7 and z <= 6:
				level = 1
			if x >= 9 and z <= 4:
				level = 2
			if x <= 2 and z >= 9:
				level = 1

			var surface: int = SurfaceKind.GRASS \
				if ((x * 5 + z * 3) % 4 != 0) else SurfaceKind.GRASS_B
			if abs(z - 6) <= 1 and x >= 2 and x <= 10:
				surface = SurfaceKind.ROAD
			if (x == 7 and z >= 3 and z <= 5) or (x == 8 and z == 4):
				surface = SurfaceKind.STONE
			if x <= 2 and z <= 2:
				surface = SurfaceKind.WATER

			height_row[x] = level
			surface_row[x] = surface
		_height_rows.append(height_row)
		_surface_rows.append(surface_row)
