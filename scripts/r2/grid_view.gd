class_name GridView
extends Node3D
## Godot adapter for the logical grid: terrain, cell colliders and selection overlay.

const CELL_SIZE: float = 1.0
const HEIGHT_STEP: float = 0.58
const BASE_Y: float = 0.42
const INVALID_COORDINATE: Vector2i = Vector2i(-1, -1)

const TEX_GRASS: Texture2D = preload("res://art/ground_grass.svg")
const TEX_GRASS_B: Texture2D = preload("res://art/ground_grass_2.svg")
const TEX_ROAD: Texture2D = preload("res://art/ground_path.svg")
const TEX_STONE: Texture2D = preload("res://art/ground_stone.svg")
const TEX_WATER: Texture2D = preload("res://art/ground_water.svg")

var grid_model: GridModel
var _top_materials: Array[StandardMaterial3D] = []
var _cliff_material: StandardMaterial3D
var _grid_overlay: MeshInstance3D
var _selection_overlay: MeshInstance3D
var _route_overlay: Node3D
var _route_marker_mesh: BoxMesh
var _route_marker_material: StandardMaterial3D
var _registered_colliders: Dictionary = {}

func configure(model: GridModel) -> bool:
	if grid_model != null or model == null or not _model_is_renderable(model):
		return false
	grid_model = model
	_build_materials()
	_build_terrain()
	_build_grid_overlay()
	_build_selection_overlay()
	_build_route_overlay()
	return _registered_colliders.size() == GridModel.WIDTH * GridModel.DEPTH

func world_position_for_cell(coordinate: Vector2i) -> Vector3:
	assert(grid_model != null and grid_model.contains(coordinate), "GridView requires a valid cell")
	var height_level: int = grid_model.height_level_at(coordinate)
	assert(height_level != GridModel.INVALID_HEIGHT, "GridView cannot transform an invalid cell")
	return Vector3(
		(float(coordinate.x) + 0.5) * CELL_SIZE,
		BASE_Y + float(height_level) * HEIGHT_STEP,
		(float(coordinate.y) + 0.5) * CELL_SIZE
	)

func set_selected_cell(coordinate: Vector2i) -> bool:
	if grid_model == null or _selection_overlay == null or not grid_model.contains(coordinate):
		return false
	_selection_overlay.position = world_position_for_cell(coordinate) + Vector3(0.0, 0.07, 0.0)
	return true

func set_grid_visible(is_visible: bool) -> void:
	if _grid_overlay != null:
		_grid_overlay.visible = is_visible

## Displays route cells after the origin; the selected destination remains yellow-highlighted.
## The route overlay is visual-only and never participates in physics picking.
func set_route_preview(path: Array[Vector2i]) -> bool:
	if grid_model == null or _route_overlay == null or path.is_empty():
		clear_route_preview()
		return false
	for coordinate in path:
		if not grid_model.contains(coordinate):
			clear_route_preview()
			return false
	clear_route_preview()
	for index in range(1, path.size()):
		var marker := MeshInstance3D.new()
		marker.name = "RouteCell_%02d" % index
		marker.mesh = _route_marker_mesh
		marker.material_override = _route_marker_material
		marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		marker.position = world_position_for_cell(path[index]) + Vector3(0.0, 0.11, 0.0)
		_route_overlay.add_child(marker)
	return true

func clear_route_preview() -> void:
	if _route_overlay == null:
		return
	for child in _route_overlay.get_children():
		child.free()

## Return INVALID_COORDINATE unless the collider is a live node registered by this view.
func coordinate_from_collider(collider: Object) -> Vector2i:
	if grid_model == null or collider == null or not is_instance_valid(collider):
		return INVALID_COORDINATE
	var tile_collider := collider as StaticBody3D
	if tile_collider == null or not tile_collider.is_inside_tree():
		return INVALID_COORDINATE
	if tile_collider.get_parent() != self or not tile_collider.is_in_group("grid_tile"):
		return INVALID_COORDINATE
	var record: Variant = _registered_colliders.get(tile_collider.get_instance_id())
	if typeof(record) != TYPE_DICTIONARY or record.is_empty():
		return INVALID_COORDINATE
	var registered_node: Variant = record.get("collider")
	var registered_coordinate: Variant = record.get("coordinate")
	if not is_instance_valid(registered_node) or registered_node != tile_collider:
		return INVALID_COORDINATE
	if typeof(registered_coordinate) != TYPE_VECTOR2I:
		return INVALID_COORDINATE
	if not tile_collider.has_meta("tile_x") or not tile_collider.has_meta("tile_z"):
		return INVALID_COORDINATE
	if not tile_collider.has_meta("height_level"):
		return INVALID_COORDINATE
	var raw_x: Variant = tile_collider.get_meta("tile_x")
	var raw_z: Variant = tile_collider.get_meta("tile_z")
	var raw_height: Variant = tile_collider.get_meta("height_level")
	if typeof(raw_x) != TYPE_INT or typeof(raw_z) != TYPE_INT or typeof(raw_height) != TYPE_INT:
		return INVALID_COORDINATE
	var coordinate := Vector2i(int(raw_x), int(raw_z))
	if coordinate != registered_coordinate or not grid_model.contains(coordinate):
		return INVALID_COORDINATE
	if int(raw_height) != grid_model.height_level_at(coordinate):
		return INVALID_COORDINATE
	return coordinate

func _model_is_renderable(model: GridModel) -> bool:
	if model.WIDTH != GridModel.WIDTH or model.DEPTH != GridModel.DEPTH:
		return false
	for z in range(model.DEPTH):
		for x in range(model.WIDTH):
			var coordinate := Vector2i(x, z)
			var height_level: int = model.height_level_at(coordinate)
			var surface_kind: int = model.surface_kind_at(coordinate)
			if height_level < 0 or surface_kind < GridModel.SurfaceKind.GRASS \
					or surface_kind > GridModel.SurfaceKind.WATER:
				return false
	return true

func _build_materials() -> void:
	var textures: Array[Texture2D] = [TEX_GRASS, TEX_GRASS_B, TEX_ROAD, TEX_STONE, TEX_WATER]
	for texture in textures:
		var material := StandardMaterial3D.new()
		material.albedo_texture = texture
		material.roughness = 1.0
		material.metallic = 0.0
		_top_materials.append(material)
	_cliff_material = StandardMaterial3D.new()
	_cliff_material.albedo_color = Color("827c7c")
	_cliff_material.roughness = 1.0

func _build_terrain() -> void:
	var plinth_mesh := BoxMesh.new()
	plinth_mesh.size = Vector3(12.45, 0.20, 12.45)
	var plinth := MeshInstance3D.new()
	plinth.mesh = plinth_mesh
	plinth.position = Vector3(float(grid_model.WIDTH) * 0.5, -0.15, float(grid_model.DEPTH) * 0.5)
	var dark_material := StandardMaterial3D.new()
	dark_material.albedo_color = Color("545b65")
	plinth.material_override = dark_material
	add_child(plinth)

	for z in range(grid_model.DEPTH):
		for x in range(grid_model.WIDTH):
			var coordinate := Vector2i(x, z)
			var surface_y := world_position_for_cell(coordinate).y
			var bedrock_mesh := BoxMesh.new()
			bedrock_mesh.size = Vector3(CELL_SIZE, surface_y - 0.02, CELL_SIZE)
			var bedrock := MeshInstance3D.new()
			bedrock.name = "Cliff_%02d_%02d" % [x, z]
			bedrock.mesh = bedrock_mesh
			bedrock.material_override = _cliff_material
			bedrock.position = Vector3(x + 0.5, (surface_y - 0.02) * 0.5, z + 0.5)
			add_child(bedrock)

			var cap_mesh := BoxMesh.new()
			cap_mesh.size = Vector3(CELL_SIZE, 0.075, CELL_SIZE)
			var cap := MeshInstance3D.new()
			cap.name = "IllustratedSurface_%02d_%02d" % [x, z]
			cap.mesh = cap_mesh
			cap.position = Vector3(x + 0.5, surface_y, z + 0.5)
			var surface_kind: int = grid_model.surface_kind_at(coordinate)
			cap.material_override = _top_materials[surface_kind]
			add_child(cap)
			_register_cell_collider(coordinate, surface_y)

func _register_cell_collider(coordinate: Vector2i, surface_y: float) -> void:
	var tile_collider := StaticBody3D.new()
	tile_collider.name = "TileCollider_%02d_%02d" % [coordinate.x, coordinate.y]
	tile_collider.add_to_group("grid_tile")
	tile_collider.set_meta("tile_x", coordinate.x)
	tile_collider.set_meta("tile_z", coordinate.y)
	tile_collider.set_meta("height_level", grid_model.height_level_at(coordinate))
	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(CELL_SIZE, surface_y + 0.03, CELL_SIZE)
	shape.shape = box_shape
	tile_collider.position = Vector3(coordinate.x + 0.5, (surface_y - 0.03) * 0.5, coordinate.y + 0.5)
	tile_collider.add_child(shape)
	add_child(tile_collider)
	_registered_colliders[tile_collider.get_instance_id()] = {
		"collider": tile_collider,
		"coordinate": coordinate,
	}

func _build_grid_overlay() -> void:
	_grid_overlay = MeshInstance3D.new()
	_grid_overlay.name = "GridOverlay"
	var immediate_mesh := ImmediateMesh.new()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	for z in range(grid_model.DEPTH):
		for x in range(grid_model.WIDTH):
			var height := world_position_for_cell(Vector2i(x, z)).y + 0.052
			var x0 := float(x) + 0.02
			var x1 := float(x) + 0.98
			var z0 := float(z) + 0.02
			var z1 := float(z) + 0.98
			var corners: Array[Vector3] = [
				Vector3(x0, height, z0), Vector3(x1, height, z0),
				Vector3(x1, height, z1), Vector3(x0, height, z1),
			]
			for edge in 4:
				immediate_mesh.surface_add_vertex(corners[edge])
				immediate_mesh.surface_add_vertex(corners[(edge + 1) % 4])
	immediate_mesh.surface_end()
	_grid_overlay.mesh = immediate_mesh
	var grid_material := StandardMaterial3D.new()
	grid_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	grid_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	grid_material.albedo_color = Color(0.13, 0.20, 0.27, 0.34)
	_grid_overlay.material_override = grid_material
	add_child(_grid_overlay)

func _build_selection_overlay() -> void:
	_selection_overlay = MeshInstance3D.new()
	_selection_overlay.name = "SelectedTile"
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(0.93, 0.025, 0.93)
	_selection_overlay.mesh = box_mesh
	var selection_material := StandardMaterial3D.new()
	selection_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	selection_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	selection_material.albedo_color = Color(0.96, 0.88, 0.49, 0.32)
	_selection_overlay.material_override = selection_material
	add_child(_selection_overlay)

func _build_route_overlay() -> void:
	_route_overlay = Node3D.new()
	_route_overlay.name = "RoutePreview"
	add_child(_route_overlay)
	_route_marker_mesh = BoxMesh.new()
	_route_marker_mesh.size = Vector3(0.42, 0.02, 0.42)
	_route_marker_material = StandardMaterial3D.new()
	_route_marker_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_route_marker_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_route_marker_material.albedo_color = Color(0.12, 0.72, 0.92, 0.75)
	_route_marker_material.cull_mode = BaseMaterial3D.CULL_DISABLED
