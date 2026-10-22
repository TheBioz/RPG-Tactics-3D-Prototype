class_name CameraController
extends Camera3D
## Owns the fixed-point camera presentation for the R2 visual prototype.

const INITIAL_YAW_DEGREES: float = 45.0
const INITIAL_PITCH_DEGREES: float = 50.0
const INITIAL_ORTHOGRAPHIC_SIZE: float = 17.0
const MIN_PITCH_DEGREES: float = 25.0
const MAX_PITCH_DEGREES: float = 78.0
const MIN_ORTHOGRAPHIC_SIZE: float = 8.0
const MAX_ORTHOGRAPHIC_SIZE: float = 24.0
const YAW_DEGREES_PER_SECOND: float = 75.0
const PITCH_DEGREES_PER_SECOND: float = 55.0
const FOCUS_DISTANCE: float = 24.0
const PICK_DISTANCE: float = 170.0
const FOCUS_POINT: Vector3 = Vector3(6.0, 0.65, 6.0)

var yaw_degrees: float = INITIAL_YAW_DEGREES
var pitch_degrees: float = INITIAL_PITCH_DEGREES
var orthographic_size: float = INITIAL_ORTHOGRAPHIC_SIZE

func _ready() -> void:
	projection = PROJECTION_ORTHOGONAL
	_update_transform()

func apply_rotation_deltas(yaw_delta: float, pitch_delta: float) -> bool:
	if not is_finite(yaw_delta) or not is_finite(pitch_delta):
		return false
	var next_yaw := yaw_degrees + yaw_delta
	var next_pitch := clampf(pitch_degrees + pitch_delta, MIN_PITCH_DEGREES, MAX_PITCH_DEGREES)
	if not is_finite(next_yaw) or not is_finite(next_pitch):
		return false
	yaw_degrees = next_yaw
	pitch_degrees = next_pitch
	_update_transform()
	return true

func apply_zoom_delta(size_delta: float) -> bool:
	if not is_finite(size_delta):
		return false
	var next_size := clampf(orthographic_size + size_delta, MIN_ORTHOGRAPHIC_SIZE, MAX_ORTHOGRAPHIC_SIZE)
	if not is_finite(next_size):
		return false
	orthographic_size = next_size
	size = orthographic_size
	return true

func reset_camera() -> void:
	yaw_degrees = INITIAL_YAW_DEGREES
	pitch_degrees = INITIAL_PITCH_DEGREES
	orthographic_size = INITIAL_ORTHOGRAPHIC_SIZE
	_update_transform()

func screen_ray(screen_position: Vector2) -> Dictionary:
	if not is_finite(screen_position.x) or not is_finite(screen_position.y):
		return {}
	var ray_origin := project_ray_origin(screen_position)
	var ray_end := ray_origin + project_ray_normal(screen_position) * PICK_DISTANCE
	return {"from": ray_origin, "to": ray_end}

func _update_transform() -> void:
	var yaw := deg_to_rad(yaw_degrees)
	var pitch := deg_to_rad(pitch_degrees)
	var offset := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * FOCUS_DISTANCE
	position = FOCUS_POINT + offset
	look_at(FOCUS_POINT, Vector3.UP)
	size = orthographic_size
