extends Node3D
## R2 movement/art harness with an R3-D1 read-only turn-status demo.
## Turn permissions are displayed from BattleState; movement remains unlinked to activations.

const TEX_HERO: Texture2D = preload("res://art/pc001_map_proxy.svg")
const TEX_TREE: Texture2D = preload("res://art/tree_birch.svg")
const TEX_TREE_B: Texture2D = preload("res://art/tree_oak.svg")
const TEX_BUSH: Texture2D = preload("res://art/bush.svg")
const TEX_FLOWERS: Texture2D = preload("res://art/flowers.svg")
const TEX_RUIN: Texture2D = preload("res://art/ruin_arch.svg")
const BattleStateScript = preload("res://scripts/r3/battle_state.gd")
const BattleStatusPresenterScript = preload("res://scripts/presentation/battle_status_presenter.gd")
const MOVEMENT_BUDGET: int = 4
const MOVEMENT_STEP_DURATION_SECONDS: float = 0.2
const MOVEMENT_TIME_EPSILON_SECONDS: float = 0.000001
const STEP_HORIZONTAL_APPROACH_FRACTION: float = 0.4
const STEP_ELEVATION_CHANGE_FRACTION: float = 0.2

enum MovementState {
	IDLE,
	MOVING,
}

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
var movement_command_service: MovementCommandService
var movement_preview: MovementCommandResult
var battle_state: BattleState
var battle_status_presenter: BattleStatusPresenter
var movement_message: String = "Selecciona una casilla para previsualizar una orden."
var movement_state: MovementState = MovementState.IDLE
var accepted_path: Array[Vector2i] = []
var _movement_segment_index: int = 0
var _movement_segment_elapsed: float = 0.0
var _movement_sprite_half_height: float = 0.0
var _accepted_destination_surface: Vector3 = Vector3.ZERO

func _ready() -> void:
	grid_model = GridModel.new()
	movement_command_service = MovementCommandService.new(MovementPathfinder.new())
	if not _configure_turn_status_demo():
		return
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

func _configure_turn_status_demo() -> bool:
	var unit_ids: Array[String] = ["player_unit_01", "player_unit_02", "enemy_unit_01", "enemy_unit_02"]
	var unit_sides: Array[StringName] = [&"PLAYER", &"PLAYER", &"ENEMY", &"ENEMY"]
	battle_state = BattleStateScript.new()
	if not battle_state.configure_round(unit_ids, unit_sides, &"PLAYER", &"ENEMY", &"PLAYER", 1):
		push_error("IsometricArtTest could not initialize the real BattleState turn demo")
		return false
	battle_status_presenter = BattleStatusPresenterScript.new()
	return true

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
	if movement_state == MovementState.MOVING:
		_advance_movement(delta)
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
		elif event.button_index == MOUSE_BUTTON_LEFT and movement_state == MovementState.IDLE:
			_pick_tile(event.position)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_G:
			show_grid = not show_grid
			grid_view.set_grid_visible(show_grid)
		elif event.keycode == KEY_B:
			if movement_state == MovementState.MOVING:
				return
			show_billboards = not show_billboards
			prop_root.visible = show_billboards
		elif event.keycode == KEY_TAB:
			if movement_state == MovementState.MOVING:
				return
			_confirm_move_order()
		elif event.keycode == KEY_V:
			if movement_state == MovementState.MOVING:
				return
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
	if movement_state == MovementState.MOVING:
		return false
	if grid_model == null or not grid_model.contains(coordinate):
		return false
	if not grid_view.set_selected_cell(coordinate):
		return false
	selected_coordinate = coordinate
	_refresh_movement_preview()
	return true

func select_grid_collider(collider: Object) -> bool:
	if grid_view == null:
		return false
	var coordinate: Vector2i = grid_view.coordinate_from_collider(collider)
	if not grid_model.contains(coordinate):
		return false
	return select_cell(coordinate)

## Direct placement helper retained for legacy regression/setup tests only.
## Player input must use _confirm_move_order() and MovementCommandService.
func move_actor_to(coordinate: Vector2i) -> bool:
	if movement_state == MovementState.MOVING:
		return false
	if not grid_model.contains(coordinate):
		return false
	if grid_model.surface_kind_at(coordinate) == GridModel.SurfaceKind.WATER:
		return false
	if not _set_actor_visual_position(coordinate):
		return false
	actor_coordinate = coordinate
	_refresh_hud()
	return true

func _refresh_movement_preview() -> void:
	if movement_state == MovementState.MOVING:
		return
	if movement_command_service == null or grid_model == null or grid_view == null:
		movement_preview = null
		movement_message = "Servicio o cuadrícula no disponible."
		if grid_view != null:
			grid_view.clear_route_preview()
		_refresh_hud()
		return
	var occupied: Array[Vector2i] = [actor_coordinate]
	movement_preview = movement_command_service.evaluate(
		grid_model, actor_coordinate, selected_coordinate, occupied, MOVEMENT_BUDGET
	)
	if movement_preview.is_accepted():
		if grid_view.set_route_preview(movement_preview.path):
			movement_message = _accepted_movement_message(movement_preview)
		else:
			movement_message = "No se pudo representar la ruta previsualizada."
	else:
		grid_view.clear_route_preview()
		movement_message = _movement_rejection_message(movement_preview)
	_refresh_hud()

func _confirm_move_order() -> bool:
	if movement_state == MovementState.MOVING:
		return false
	movement_preview = null
	if movement_command_service == null or grid_model == null or grid_view == null:
		movement_message = "Servicio o cuadrícula no disponible."
		_refresh_hud()
		return false
	var occupied: Array[Vector2i] = [actor_coordinate]
	var confirmation := movement_command_service.evaluate(
		grid_model, actor_coordinate, selected_coordinate, occupied, MOVEMENT_BUDGET
	)
	if not confirmation.is_accepted():
		movement_preview = null
		grid_view.clear_route_preview()
		movement_message = _movement_rejection_message(confirmation)
		_refresh_hud()
		return false
	if selected_coordinate == actor_coordinate:
		movement_preview = null
		grid_view.clear_route_preview()
		movement_message = "El actor ya está en esa casilla (coste 0)."
		_refresh_hud()
		return true
	var presentation_error := _movement_presentation_error(selected_coordinate)
	if not presentation_error.is_empty():
		movement_preview = null
		grid_view.clear_route_preview()
		movement_message = presentation_error
		_refresh_hud()
		return false
	var initial_half_height: float = _sprite_half_height(hero.texture, hero.pixel_size)
	if initial_half_height <= 0.0 or not _set_actor_visual_position(actor_coordinate):
		movement_preview = null
		grid_view.clear_route_preview()
		movement_message = "No se pudo sincronizar la pose inicial; orden no aplicada."
		_refresh_hud()
		return false
	if not grid_view.set_route_preview(confirmation.path):
		movement_preview = null
		grid_view.clear_route_preview()
		movement_message = "No se pudo mostrar la ruta aprobada; orden no aplicada."
		_refresh_hud()
		return false
	accepted_path = confirmation.path.duplicate()
	_accepted_destination_surface = grid_view.world_position_for_cell(selected_coordinate)
	_movement_segment_index = 0
	_movement_segment_elapsed = 0.0
	_movement_sprite_half_height = initial_half_height
	movement_preview = null
	movement_state = MovementState.MOVING
	actor_coordinate = selected_coordinate
	movement_message = "Movimiento en curso: coste %d/%d." % [confirmation.total_cost, MOVEMENT_BUDGET]
	_refresh_hud()
	return true

func _advance_movement(delta: float) -> void:
	if movement_state != MovementState.MOVING or not is_finite(delta) or delta <= 0.0:
		return
	if not _movement_visual_resources_are_valid():
		_abort_movement_presentation("Faltan recursos visuales durante el movimiento.")
		return
	if accepted_path.size() < 2 or _movement_segment_index >= accepted_path.size() - 1:
		_abort_movement_presentation("La ruta aceptada perdió su estructura.")
		return
	var remaining_delta: float = delta
	while remaining_delta > 0.0 and movement_state == MovementState.MOVING:
		var segment_remaining := MOVEMENT_STEP_DURATION_SECONDS - _movement_segment_elapsed
		var segment_delta := minf(remaining_delta, segment_remaining)
		_movement_segment_elapsed += segment_delta
		remaining_delta -= segment_delta
		var progress := clampf(_movement_segment_elapsed / MOVEMENT_STEP_DURATION_SECONDS, 0.0, 1.0)
		if not _apply_movement_segment(_movement_segment_index, progress):
			_abort_movement_presentation("No se pudo presentar un tramo de la ruta.")
			return
		if _movement_segment_elapsed + MOVEMENT_TIME_EPSILON_SECONDS >= MOVEMENT_STEP_DURATION_SECONDS:
			_movement_segment_elapsed = MOVEMENT_STEP_DURATION_SECONDS
			if not _apply_movement_segment(_movement_segment_index, 1.0):
				_abort_movement_presentation("No se pudo sincronizar el final de un tramo.")
				return
			_movement_segment_index += 1
			_movement_segment_elapsed = 0.0
			if _movement_segment_index >= accepted_path.size() - 1:
				_complete_movement_presentation()
				return

func _apply_movement_segment(segment_index: int, progress: float) -> bool:
	if not _movement_visual_resources_are_valid():
		return false
	var source := grid_view.world_position_for_cell(accepted_path[segment_index])
	var destination := grid_view.world_position_for_cell(accepted_path[segment_index + 1])
	var actor_x: float
	var actor_z: float
	var actor_surface_y: float
	var shadow_surface_y: float
	if is_equal_approx(source.y, destination.y):
		var flat_position := source.lerp(destination, progress)
		actor_x = flat_position.x
		actor_z = flat_position.z
		actor_surface_y = source.y
		shadow_surface_y = source.y
	else:
		var edge_x := (source.x + destination.x) * 0.5
		var edge_z := (source.z + destination.z) * 0.5
		if progress < STEP_HORIZONTAL_APPROACH_FRACTION:
			var approach := progress / STEP_HORIZONTAL_APPROACH_FRACTION
			actor_x = lerpf(source.x, edge_x, approach)
			actor_z = lerpf(source.z, edge_z, approach)
			actor_surface_y = source.y
			shadow_surface_y = source.y
		elif progress < STEP_HORIZONTAL_APPROACH_FRACTION + STEP_ELEVATION_CHANGE_FRACTION:
			var transition_progress := (progress - STEP_HORIZONTAL_APPROACH_FRACTION) \
				/ STEP_ELEVATION_CHANGE_FRACTION
			var eased_transition := transition_progress * transition_progress \
				* (3.0 - 2.0 * transition_progress)
			actor_x = edge_x
			actor_z = edge_z
			actor_surface_y = lerpf(source.y, destination.y, eased_transition)
			shadow_surface_y = source.y
		else:
			var departure_start := STEP_HORIZONTAL_APPROACH_FRACTION + STEP_ELEVATION_CHANGE_FRACTION
			var departure := (progress - departure_start) / (1.0 - departure_start)
			actor_x = lerpf(edge_x, destination.x, departure)
			actor_z = lerpf(edge_z, destination.z, departure)
			actor_surface_y = destination.y
			shadow_surface_y = destination.y
	var actor_position := Vector3(actor_x, actor_surface_y + _movement_sprite_half_height, actor_z)
	var shadow_position := Vector3(actor_x, shadow_surface_y + 0.048, actor_z)
	hero.position = actor_position
	hero_shadow.position = shadow_position
	return true

func _movement_visual_resources_are_valid() -> bool:
	if not is_instance_valid(hero) or hero.texture == null:
		return false
	var current_half_height: float = _sprite_half_height(hero.texture, hero.pixel_size)
	return is_instance_valid(grid_view) and grid_view.grid_model == grid_model \
		and hero.is_inside_tree() \
		and is_instance_valid(hero_shadow) and hero_shadow.is_inside_tree() \
		and is_instance_valid(prop_root) and prop_root.visible \
		and hero.is_visible_in_tree() and hero_shadow.is_visible_in_tree() \
		and current_half_height > 0.0 \
		and is_equal_approx(current_half_height, _movement_sprite_half_height)

func _complete_movement_presentation() -> void:
	if not _set_actor_visual_position(actor_coordinate):
		_abort_movement_presentation("No se pudo sincronizar la pose final.")
		return
	accepted_path.clear()
	_movement_segment_index = 0
	_movement_segment_elapsed = 0.0
	_movement_sprite_half_height = 0.0
	_accepted_destination_surface = Vector3.ZERO
	movement_preview = null
	movement_state = MovementState.IDLE
	grid_view.clear_route_preview()
	movement_message = "Movimiento completado."
	_refresh_hud()

func _abort_movement_presentation(message: String) -> void:
	# The logical destination was committed on acceptance; never roll it back partially.
	_sync_available_actor_visuals_at_accepted_destination()
	accepted_path.clear()
	_movement_segment_index = 0
	_movement_segment_elapsed = 0.0
	_movement_sprite_half_height = 0.0
	_accepted_destination_surface = Vector3.ZERO
	movement_preview = null
	movement_state = MovementState.IDLE
	if is_instance_valid(grid_view):
		grid_view.clear_route_preview()
	movement_message = message
	_refresh_hud()

func _sync_available_actor_visuals_at_accepted_destination() -> void:
	if is_instance_valid(hero):
		var half_height := _sprite_half_height(hero.texture, hero.pixel_size)
		if half_height > 0.0:
			hero.position = _accepted_destination_surface + Vector3(0.0, half_height, 0.0)
	if is_instance_valid(hero_shadow):
		hero_shadow.position = _accepted_destination_surface + Vector3(0.0, 0.048, 0.0)

func _movement_presentation_error(destination: Vector2i) -> String:
	if grid_view == null or not is_instance_valid(grid_view) or grid_view.grid_model != grid_model:
		return "GridView no está disponible."
	if not grid_model.contains(destination):
		return "Destino fuera de la cuadrícula."
	if not is_instance_valid(hero) or not hero.is_inside_tree():
		return "El proxy del actor no está disponible."
	if not is_instance_valid(hero_shadow) or not hero_shadow.is_inside_tree():
		return "La sombra del actor no está disponible."
	if not is_instance_valid(prop_root) or not prop_root.visible or not hero.is_visible_in_tree() \
			or not hero_shadow.is_visible_in_tree():
		return "Activa los props (B) para mostrar el movimiento."
	if _sprite_half_height(hero.texture, hero.pixel_size) <= 0.0:
		return "La textura o escala del proxy no permite presentar el movimiento."
	return ""

func _set_actor_visual_position(coordinate: Vector2i) -> bool:
	if grid_model == null or not is_instance_valid(grid_view) or not grid_model.contains(coordinate):
		return false
	if not is_instance_valid(hero) or not is_instance_valid(hero_shadow):
		return false
	var half_height: float = _sprite_half_height(hero.texture, hero.pixel_size)
	if half_height <= 0.0:
		return false
	var surface_position: Vector3 = grid_view.world_position_for_cell(coordinate)
	var hero_position := surface_position + Vector3(0.0, half_height, 0.0)
	var shadow_position := surface_position + Vector3(0.0, 0.048, 0.0)
	hero.position = hero_position
	hero_shadow.position = shadow_position
	return true

func _accepted_movement_message(result: MovementCommandResult) -> String:
	if result.path.size() <= 1:
		return "El actor ya está en esa casilla (coste 0)."
	return "Ruta disponible: coste %d/%d. TAB confirma." % [result.total_cost, MOVEMENT_BUDGET]

func _movement_rejection_message(result: MovementCommandResult) -> String:
	match result.status:
		MovementCommandResult.Status.INVALID_MODEL:
			return "No hay un modelo de cuadrícula válido."
		MovementCommandResult.Status.INVALID_START:
			return "El origen del actor no es válido."
		MovementCommandResult.Status.INVALID_DESTINATION:
			return "El destino está fuera de la cuadrícula."
		MovementCommandResult.Status.INVALID_BUDGET:
			return "El presupuesto de movimiento no es válido."
		MovementCommandResult.Status.IMPASSABLE_START:
			return "El actor no puede iniciar desde esa casilla."
		MovementCommandResult.Status.ILLEGAL_DESTINATION:
			return "Destino intransitable (agua o datos de casilla inválidos)."
		MovementCommandResult.Status.DESTINATION_OCCUPIED:
			return "El destino está ocupado."
		MovementCommandResult.Status.NO_PATH:
			return "No existe una ruta legal hasta el destino."
		MovementCommandResult.Status.INSUFFICIENT_BUDGET:
			return "Coste %d: supera el presupuesto %d." % [result.total_cost, MOVEMENT_BUDGET]
		MovementCommandResult.Status.INCONSISTENT_PATHFINDER_RESULT:
			return "El cálculo de ruta devolvió un resultado inconsistente."
		_:
			return "Orden de movimiento rechazada."

func apply_actor_texture(texture: Texture2D) -> bool:
	if movement_state == MovementState.MOVING:
		return false
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
	if not is_instance_valid(hud_text) or grid_model == null \
			or not grid_model.contains(selected_coordinate) or not is_instance_valid(camera):
		return
	var selected_height: int = grid_model.height_level_at(selected_coordinate)
	assert(selected_height != GridModel.INVALID_HEIGHT, "HUD selection must be valid")
	hud_text.text = "Casilla: (%d, %d)   Altura: %d\nCam yaw: %.0f°   pitch: %.0f°   zoom: %.1f\nPC-001: proxy anime 2D / facing gráfico a cámara\nFacing lógico de mundo: independiente (por implementar)\nActor: %s" % [selected_coordinate.x, selected_coordinate.y, selected_height, camera.yaw_degrees, camera.pitch_degrees, camera.orthographic_size, "Ilustración C0 (NO mini anime)" if use_reference else "Proxy SVG de producción (NO canon)"]
	hud_text.text += "\nActor lógico: (%d, %d)   Presupuesto provisional: %d" % [
		actor_coordinate.x, actor_coordinate.y, MOVEMENT_BUDGET,
	]
	hud_text.text += "\nMovimiento: %s" % movement_message
	if is_instance_valid(battle_status_presenter):
		hud_text.text += "\n\n" + battle_status_presenter.format_status(battle_state)
