extends Node3D
## Art feasibility PoC. No tactical runtime, pathfinding or character animation.
## All props and actor are 2D illustrations. Only terrain, walls and floor use 3D boxes.

const TEX_HERO: Texture2D = preload("res://art/pc001_map_proxy.svg")
const TEX_TREE: Texture2D = preload("res://art/tree_birch.svg")
const TEX_TREE_B: Texture2D = preload("res://art/tree_oak.svg")
const TEX_BUSH: Texture2D = preload("res://art/bush.svg")
const TEX_FLOWERS: Texture2D = preload("res://art/flowers.svg")
const TEX_RUIN: Texture2D = preload("res://art/ruin_arch.svg")

@onready var camera: CameraController = $Camera3D
var grid_model: GridModel
var grid_view: GridView
var show_grid: bool = true
var show_billboards: bool = true
var hero: Sprite3D
var hero_shadow: MeshInstance3D
var use_reference: bool = false
var reference_texture: Texture2D
var prop_root: Node3D
var hud_text: Label
var selected_coordinate: Vector2i = Vector2i(5, 6)
var actor_coordinate: Vector2i = Vector2i(5, 6)

func _ready() -> void:
	grid_model = GridModel.new()
	grid_view = GridView.new()
	grid_view.name = "GridView"
	add_child(grid_view)
	if not grid_view.configure(grid_model):
		push_error("IsometricArtTest could not configure GridView from GridModel")
		return
	if not grid_view.set_selected_cell(selected_coordinate):
		push_error("IsometricArtTest could not initialize GridView selection")
		return
	prop_root = Node3D.new()
	prop_root.name = "PaintedProps2D"
	add_child(prop_root)
	_build_props()
	if ResourceLoader.exists("res://art/pc001_reference_character.png"):
		reference_texture = load("res://art/pc001_reference_character.png") as Texture2D
	_build_world_light()
	_build_hud()
	_refresh_hud()

func _spawn_sprite(tex: Texture2D, x: int, z: int, height: float, pixel: float) -> Sprite3D:
	var s := Sprite3D.new()
	s.texture = tex
	s.pixel_size = pixel
	s.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	s.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	s.shaded = false
	s.double_sided = true
	var cell_coordinate := Vector2i(x, z)
	var surface_position := grid_view.world_position_for_cell(cell_coordinate)
	s.position = surface_position + Vector3(0, float(tex.get_height()) * pixel * 0.5, 0)
	prop_root.add_child(s)
	var sh := _add_shadow(surface_position + Vector3(0, 0.048, 0), 0.35 if height < 1.7 else 0.58)
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

func _process(delta: float) -> void:
	var yaw_delta := 0.0
	var pitch_delta := 0.0
	if Input.is_key_pressed(KEY_Q):
		yaw_delta -= CameraController.YAW_DEGREES_PER_SECOND * delta
	if Input.is_key_pressed(KEY_E):
		yaw_delta += CameraController.YAW_DEGREES_PER_SECOND * delta
	if Input.is_key_pressed(KEY_R):
		pitch_delta += CameraController.PITCH_DEGREES_PER_SECOND * delta
	if Input.is_key_pressed(KEY_F):
		pitch_delta -= CameraController.PITCH_DEGREES_PER_SECOND * delta
	if yaw_delta != 0.0 or pitch_delta != 0.0:
		if camera.apply_rotation_deltas(yaw_delta, pitch_delta):
			_refresh_hud()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.apply_zoom_delta(-1.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.apply_zoom_delta(1.0)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			_pick_tile(event.position)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_G:
			show_grid = not show_grid
			grid_view.set_grid_visible(show_grid)
		elif event.keycode == KEY_B:
			show_billboards = not show_billboards
			prop_root.visible = show_billboards
		elif event.keycode == KEY_TAB:
			_move_proxy()
		elif event.keycode == KEY_V:
			_toggle_actor_reference()
		elif event.keycode == KEY_HOME:
			camera.reset_camera()
		_refresh_hud()

func _pick_tile(mouse_pos: Vector2) -> void:
	var ray: Dictionary = camera.screen_ray(mouse_pos)
	if ray.is_empty():
		return
	var query := PhysicsRayQueryParameters3D.create(ray["from"], ray["to"])
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	select_grid_collider(hit.get("collider"))

func select_cell(coordinate: Vector2i) -> bool:
	if not grid_model.contains(coordinate):
		return false
	if not grid_view.set_selected_cell(coordinate):
		return false
	selected_coordinate = coordinate
	_refresh_hud()
	return true

func select_grid_collider(collider: Object) -> bool:
	if grid_view == null:
		return false
	var coordinate: Vector2i = grid_view.coordinate_from_collider(collider)
	if not grid_model.contains(coordinate):
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
	var at := grid_view.world_position_for_cell(coordinate)
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
	var at := grid_view.world_position_for_cell(actor_coordinate)
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
	hud_text.text = "Casilla: (%d, %d)   Altura: %d\nCam yaw: %.0f°   pitch: %.0f°   zoom: %.1f\nPC-001: proxy anime 2D / facing gráfico a cámara\nFacing lógico de mundo: independiente (por implementar)\nActor: %s" % [selected_coordinate.x, selected_coordinate.y, selected_height, camera.yaw_degrees, camera.pitch_degrees, camera.orthographic_size, "Ilustración C0 (NO mini anime)" if use_reference else "Proxy SVG de producción (NO canon)"]
