extends Node3D
## Art feasibility PoC. No tactical runtime, pathfinding or character animation.
## All props and actor are 2D illustrations. Only terrain, walls and floor use 3D boxes.

const CELL: float = 1.0
const STEP_Y: float = 0.58
const BASE_Y: float = 0.42

const TEX_GRASS: Texture2D = preload("res://art/ground_grass.svg")
const TEX_GRASS_B: Texture2D = preload("res://art/ground_grass_2.svg")
const TEX_ROAD: Texture2D = preload("res://art/ground_path.svg")
const TEX_STONE: Texture2D = preload("res://art/ground_stone.svg")
const TEX_WATER: Texture2D = preload("res://art/ground_water.svg")
const TEX_HERO: Texture2D = preload("res://art/pc001_map_proxy.svg")
const TEX_TREE: Texture2D = preload("res://art/tree_birch.svg")
const TEX_TREE_B: Texture2D = preload("res://art/tree_oak.svg")
const TEX_BUSH: Texture2D = preload("res://art/bush.svg")
const TEX_FLOWERS: Texture2D = preload("res://art/flowers.svg")
const TEX_RUIN: Texture2D = preload("res://art/ruin_arch.svg")

@onready var camera: Camera3D = $Camera3D
var grid_model: GridModel
var top_materials: Array[StandardMaterial3D] = []
var cliff_material: StandardMaterial3D
var camera_yaw: float = 45.0
var camera_pitch: float = 50.0
var camera_size: float = 17.0
var show_grid: bool = true
var show_billboards: bool = true
var hero: Sprite3D
var hero_shadow: MeshInstance3D
var use_reference: bool = false
var reference_texture: Texture2D
var terrain_root: Node3D
var prop_root: Node3D
var selection: MeshInstance3D
var grid_draw: MeshInstance3D
var hud_text: Label
var selected_coordinate: Vector2i = Vector2i(5, 6)
var actor_coordinate: Vector2i = Vector2i(5, 6)

func _ready() -> void:
	grid_model = GridModel.new()
	terrain_root = Node3D.new()
	terrain_root.name = "Terrain3D"
	add_child(terrain_root)
	prop_root = Node3D.new()
	prop_root.name = "PaintedProps2D"
	add_child(prop_root)
	_build_materials()
	_build_terrain()
	_build_props()
	if ResourceLoader.exists("res://art/pc001_reference_character.png"):
		reference_texture = load("res://art/pc001_reference_character.png") as Texture2D
	_build_selection()
	_build_world_light()
	_build_hud()
	_update_camera()
	_refresh_hud()

func _build_materials() -> void:
	var textures: Array[Texture2D] = [TEX_GRASS, TEX_GRASS_B, TEX_ROAD, TEX_STONE, TEX_WATER]
	for tex in textures:
		var m := StandardMaterial3D.new()
		m.albedo_texture = tex
		m.roughness = 1.0
		m.metallic = 0.0
		top_materials.append(m)
	cliff_material = StandardMaterial3D.new()
	cliff_material.albedo_color = Color("827c7c")
	cliff_material.roughness = 1.0

func _surface_top(x: int, z: int) -> float:
	var coordinate := Vector2i(x, z)
	var height_level: int = grid_model.height_level_at(coordinate)
	assert(height_level != GridModel.INVALID_HEIGHT, "Cannot render an invalid grid coordinate")
	return BASE_Y + float(height_level) * STEP_Y

func _tile_center(x: int, z: int) -> Vector3:
	var coordinate := Vector2i(x, z)
	assert(grid_model.contains(coordinate), "Cannot position a view at an invalid grid coordinate")
	return Vector3((float(x) + 0.5) * CELL, _surface_top(x, z), (float(z) + 0.5) * CELL)

func _build_terrain() -> void:
	var plinth_mesh := BoxMesh.new()
	plinth_mesh.size = Vector3(12.45, 0.20, 12.45)
	var plinth := MeshInstance3D.new()
	plinth.mesh = plinth_mesh
	plinth.position = Vector3(6, -0.15, 6)
	var dark_mat := StandardMaterial3D.new()
	dark_mat.albedo_color = Color("545b65")
	plinth.material_override = dark_mat
	terrain_root.add_child(plinth)
	for z in range(GridModel.DEPTH):
		for x in range(GridModel.WIDTH):
			var top: float = _surface_top(x, z)
			var base_mesh := BoxMesh.new()
			base_mesh.size = Vector3(CELL, top - 0.02, CELL)
			var bedrock := MeshInstance3D.new()
			bedrock.name = "Cliff_%02d_%02d" % [x,z]
			bedrock.mesh = base_mesh
			bedrock.material_override = cliff_material
			bedrock.position = Vector3(x + 0.5, (top - 0.02) / 2.0, z + 0.5)
			terrain_root.add_child(bedrock)
			var cap_mesh := BoxMesh.new()
			cap_mesh.size = Vector3(1.0, 0.075, 1.0)
			var cap := MeshInstance3D.new()
			cap.mesh = cap_mesh
			cap.name = "IllustratedSurface_%02d_%02d" % [x,z]
			cap.position = Vector3(x + 0.5, top, z + 0.5)
			var surface_kind: int = grid_model.surface_kind_at(Vector2i(x, z))
			assert(surface_kind != GridModel.INVALID_SURFACE, "Cannot render an invalid grid surface")
			cap.material_override = top_materials[surface_kind]
			terrain_root.add_child(cap)
			var tile_body := StaticBody3D.new()
			tile_body.name = "TileCollider_%02d_%02d" % [x,z]
			tile_body.add_to_group("grid_tile")
			tile_body.set_meta("tile_x", x)
			tile_body.set_meta("tile_z", z)
			tile_body.set_meta("height_level", grid_model.height_level_at(Vector2i(x, z)))
			var shape := CollisionShape3D.new()
			var box_shape := BoxShape3D.new()
			box_shape.size = Vector3(CELL, top + 0.03, CELL)
			shape.shape = box_shape
			tile_body.position = Vector3(x + 0.5, (top - 0.03) / 2.0, z + 0.5)
			tile_body.add_child(shape)
			terrain_root.add_child(tile_body)
	_build_grid()

func _spawn_sprite(tex: Texture2D, x: int, z: int, height: float, pixel: float) -> Sprite3D:
	var s := Sprite3D.new()
	s.texture = tex
	s.pixel_size = pixel
	s.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	s.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	s.shaded = false
	s.double_sided = true
	var top := _surface_top(x, z)
	s.position = Vector3(x + 0.5, top + float(tex.get_height()) * pixel * 0.5, z + 0.5)
	prop_root.add_child(s)
	var sh := _add_shadow(Vector3(x + 0.5, top + 0.048, z + 0.5), 0.35 if height < 1.7 else 0.58)
	if tex == TEX_HERO:
		hero_shadow = sh
	return s

func _add_shadow(pos: Vector3, radius: float) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.009
	mesh.radial_segments = 24
	var inst := MeshInstance3D.new()
	inst.mesh = mesh
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(0.08, 0.12, 0.20, 0.19)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	inst.material_override = m
	inst.position = pos
	prop_root.add_child(inst)
	return inst

func _build_props() -> void:
	# Tree and bush illustrations are 2D, never meshes. Their planes stay upright.
	var trees: Array[Vector2i] = [Vector2i(0, 4), Vector2i(2, 3), Vector2i(3, 1), Vector2i(5, 2), Vector2i(10, 9), Vector2i(11, 5), Vector2i(1, 11), Vector2i(3, 10)]
	for i in trees.size():
		var t := trees[i]
		_spawn_sprite(TEX_TREE if i % 2 == 0 else TEX_TREE_B, t.x, t.y, 2.85, 0.0059)
	var bushes: Array[Vector2i] = [Vector2i(1, 5), Vector2i(3, 4), Vector2i(6, 2), Vector2i(8, 8), Vector2i(10, 7), Vector2i(5, 10), Vector2i(4, 0)]
	for t in bushes:
		_spawn_sprite(TEX_BUSH, t.x, t.y, 0.82, 0.003)
	var flowers: Array[Vector2i] = [Vector2i(4, 3), Vector2i(5, 4), Vector2i(6, 8), Vector2i(8, 9), Vector2i(3, 8), Vector2i(10, 11)]
	for t in flowers:
		_spawn_sprite(TEX_FLOWERS, t.x, t.y, 0.40, 0.0024)
	# Illustrated ruin facade (not a real wall obstacle in the gameplay).
	_spawn_sprite(TEX_RUIN, 10, 2, 2.5, 0.0054)
	_spawn_sprite(TEX_RUIN, 9, 0, 2.5, 0.0054)
	# Portrait-proxy test actor; does NOT prove mini-anime consistency yet.
	hero = _spawn_sprite(TEX_HERO, 5, 6, 1.65, 0.00325)
	hero.name = "PC001_IllustratedMapProxy_NOT_CANON"

func _build_grid() -> void:
	grid_draw = MeshInstance3D.new()
	grid_draw.name = "GridOverlay"
	var im := ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_LINES)
	for z in range(GridModel.DEPTH):
		for x in range(GridModel.WIDTH):
			var h := _surface_top(x, z) + 0.052
			var x0 := float(x) + 0.02
			var x1 := float(x) + 0.98
			var z0 := float(z) + 0.02
			var z1 := float(z) + 0.98
			for edge in 4:
				var v0 := Vector3(x0, h, z0)
				var v1 := Vector3(x1, h, z0)
				if edge == 1:
					v0 = Vector3(x1, h, z0)
					v1 = Vector3(x1, h, z1)
				elif edge == 2:
					v0 = Vector3(x1, h, z1)
					v1 = Vector3(x0, h, z1)
				elif edge == 3:
					v0 = Vector3(x0, h, z1)
					v1 = Vector3(x0, h, z0)
				im.surface_add_vertex(v0)
				im.surface_add_vertex(v1)
	im.surface_end()
	grid_draw.mesh = im
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(0.13, 0.20, 0.27, 0.34)
	grid_draw.material_override = m
	terrain_root.add_child(grid_draw)

func _build_selection() -> void:
	selection = MeshInstance3D.new()
	selection.name = "SelectedTile"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.93, 0.025, 0.93)
	selection.mesh = mesh
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(0.96, 0.88, 0.49, 0.32)
	selection.material_override = m
	terrain_root.add_child(selection)
	_update_selection()

func _update_selection() -> void:
	assert(grid_model.contains(selected_coordinate), "Selection must be a valid grid coordinate")
	selection.position = _tile_center(selected_coordinate.x, selected_coordinate.y) + Vector3(0, 0.07, 0)

func _build_world_light() -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-60, -35, 0)
	light.light_energy = 0.84
	light.shadow_enabled = false
	add_child(light)
	var env := WorldEnvironment.new()
	var res := Environment.new()
	res.background_mode = Environment.BG_COLOR
	res.background_color = Color("cad9dc")
	res.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	res.ambient_light_color = Color("f2eadd")
	res.ambient_light_energy = 0.8
	env.environment = res
	add_child(env)

func _build_hud() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var box := PanelContainer.new()
	box.position = Vector2(18, 16)
	box.custom_minimum_size = Vector2(405, 0)
	canvas.add_child(box)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 5)
	box.add_child(layout)
	var title := Label.new()
	title.text = "RTM   /   PRUEBA ISOMÉTRICA 2D+3D"
	title.add_theme_font_size_override("font_size", 19)
	layout.add_child(title)
	hud_text = Label.new()
	hud_text.add_theme_font_size_override("font_size", 14)
	layout.add_child(hud_text)
	var instructions := Label.new()
	instructions.text = "Q/E girar · R/F inclinar · rueda zoom\nClick casilla · G grid · B props · TAB mover proxy\nV cambiar personaje (solo ZIP) · HOME restablecer"
	layout.add_child(instructions)
	var bottom := Label.new()
	bottom.position = Vector2(18, 856)
	bottom.text = "ARTE VECTORIAL PROVISIONAL — no valida consistencia IA ni calidad final"
	bottom.add_theme_color_override("font_color", Color("2c3f4b"))
	canvas.add_child(bottom)

func _update_camera() -> void:
	var anchor := Vector3(6, 0.65, 6)
	var yaw := deg_to_rad(camera_yaw)
	var pitch := deg_to_rad(camera_pitch)
	var distance := 24.0
	var offset := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * distance
	camera.position = anchor + offset
	camera.look_at(anchor, Vector3.UP)
	camera.size = camera_size

func _process(delta: float) -> void:
	var changed := false
	if Input.is_key_pressed(KEY_Q):
		camera_yaw -= 75.0 * delta
		changed = true
	if Input.is_key_pressed(KEY_E):
		camera_yaw += 75.0 * delta
		changed = true
	if Input.is_key_pressed(KEY_R):
		camera_pitch = clampf(camera_pitch + 55.0 * delta, 25.0, 78.0)
		changed = true
	if Input.is_key_pressed(KEY_F):
		camera_pitch = clampf(camera_pitch - 55.0 * delta, 25.0, 78.0)
		changed = true
	if changed:
		_update_camera()
		_refresh_hud()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_size = clampf(camera_size - 1.0, 8.0, 24.0)
			_update_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_size = clampf(camera_size + 1.0, 8.0, 24.0)
			_update_camera()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			_pick_tile(event.position)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_G:
			show_grid = not show_grid
			grid_draw.visible = show_grid
		elif event.keycode == KEY_B:
			show_billboards = not show_billboards
			prop_root.visible = show_billboards
		elif event.keycode == KEY_TAB:
			_move_proxy()
		elif event.keycode == KEY_V:
			_toggle_actor_reference()
		elif event.keycode == KEY_HOME:
			camera_yaw = 45.0
			camera_pitch = 50.0
			camera_size = 17.0
			_update_camera()
		_refresh_hud()

func _pick_tile(mouse_pos: Vector2) -> void:
	var from := camera.project_ray_origin(mouse_pos)
	var to := from + camera.project_ray_normal(mouse_pos) * 170.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	select_grid_collider(hit.get("collider"))

func select_cell(coordinate: Vector2i) -> bool:
	if not grid_model.contains(coordinate):
		return false
	selected_coordinate = coordinate
	_update_selection()
	_refresh_hud()
	return true

func select_grid_collider(collider: Object) -> bool:
	if collider == null or not is_instance_valid(collider):
		return false
	var tile_collider := collider as StaticBody3D
	if tile_collider == null or not tile_collider.is_in_group("grid_tile"):
		return false
	if not tile_collider.has_meta("tile_x") or not tile_collider.has_meta("tile_z"):
		return false
	var raw_x: Variant = tile_collider.get_meta("tile_x")
	var raw_z: Variant = tile_collider.get_meta("tile_z")
	if typeof(raw_x) != TYPE_INT or typeof(raw_z) != TYPE_INT:
		return false
	var coordinate := Vector2i(int(raw_x), int(raw_z))
	if not grid_model.contains(coordinate):
		return false
	if not tile_collider.has_meta("height_level"):
		return false
	var raw_height: Variant = tile_collider.get_meta("height_level")
	if typeof(raw_height) != TYPE_INT or int(raw_height) != grid_model.height_level_at(coordinate):
		return false
	return select_cell(coordinate)

func move_actor_to(coordinate: Vector2i) -> bool:
	if not grid_model.contains(coordinate):
		return false
	if grid_model.surface_kind_at(coordinate) == GridModel.SurfaceKind.WATER:
		return false
	if hero == null or hero_shadow == null:
		return false
	var half_height: float = _sprite_half_height(hero.texture, hero.pixel_size)
	if half_height <= 0.0:
		return false
	var at := _tile_center(coordinate.x, coordinate.y)
	actor_coordinate = coordinate
	hero.position = at + Vector3(0, half_height, 0)
	hero_shadow.position = at + Vector3(0, 0.048, 0)
	_refresh_hud()
	return true

func _move_proxy() -> void:
	move_actor_to(selected_coordinate)

func apply_actor_texture(texture: Texture2D) -> bool:
	if texture == null or hero == null or hero_shadow == null:
		return false
	if not grid_model.contains(actor_coordinate):
		return false
	var texture_width: int = texture.get_width()
	var texture_height: int = texture.get_height()
	if texture_width <= 0 or texture_height <= 0:
		return false
	var new_pixel_size: float = 1.65 / float(texture_height)
	if not is_finite(new_pixel_size) or new_pixel_size <= 0.0:
		return false
	var half_height: float = _sprite_half_height(texture, new_pixel_size)
	if half_height <= 0.0:
		return false
	var at := _tile_center(actor_coordinate.x, actor_coordinate.y)
	hero.texture = texture
	hero.pixel_size = new_pixel_size
	hero.position = at + Vector3(0, half_height, 0)
	hero_shadow.position = at + Vector3(0, 0.048, 0)
	return true

func _sprite_half_height(texture: Texture2D, pixel_size: float) -> float:
	if texture == null or texture.get_width() <= 0 or texture.get_height() <= 0:
		return -1.0
	if not is_finite(pixel_size) or pixel_size <= 0.0:
		return -1.0
	return float(texture.get_height()) * pixel_size * 0.5

func _toggle_actor_reference() -> void:
	if reference_texture == null:
		return
	var next_use_reference := not use_reference
	var tex: Texture2D = reference_texture if next_use_reference else TEX_HERO
	if apply_actor_texture(tex):
		use_reference = next_use_reference
		_refresh_hud()

func _refresh_hud() -> void:
	if hud_text == null:
		return
	var selected_height: int = grid_model.height_level_at(selected_coordinate)
	assert(selected_height != GridModel.INVALID_HEIGHT, "HUD selection must be valid")
	hud_text.text = "Casilla: (%d, %d)   Altura: %d\nCam yaw: %.0f°   pitch: %.0f°   zoom: %.1f\nPC-001: proxy anime 2D / facing gráfico a cámara\nFacing lógico de mundo: independiente (por implementar)\nActor: %s" % [selected_coordinate.x, selected_coordinate.y, selected_height, camera_yaw, camera_pitch, camera_size, "Ilustración C0 (NO mini anime)" if use_reference else "Proxy SVG de producción (NO canon)"]
