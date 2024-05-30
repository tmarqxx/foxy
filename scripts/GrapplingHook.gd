class_name GrapplingHook
extends Node3D

signal hook_engaged

@export var player : Player
@export var max_rope_length : float = 16.0
@export_range(0, 10) var time_to_hook : float = 0.0
@export_range(1.0, 100.0) var mass : float = 1.0
@export var test_hook_point : Node3D

@onready var timer : Timer = $Timer
@onready var caster : ShapeCast3D = $ShapeCast3D

var hook_point: Node3D = null

var _is_hooked : bool = false
var tension_vector : Vector3 = Vector3.ZERO
var pendulum_angle : float = 0.0
var start_position : Vector3 = Vector3.ZERO

func throw_hook() -> bool:
	print("IS COLLIDING: ", caster.is_colliding())
	if not caster.is_colliding():
		return false
	
	hook_point = caster.get_collider(0).get_hook_point()
	print(hook_point.global_position)
	timer.start()
	print("TIMER START")
	return true
	# trigger animation

func _engage_hook():
	print("TIMEOUT")
	hook_engaged.emit()
	_is_hooked = true
	start_position = self.global_position
	

func release_hook():
	_is_hooked = false
	start_position = Vector3.ZERO

func is_hooked():
	return _is_hooked

#func get_angular_velocity() -> Vector3:
	#return mass * player.get_gravity() * Vector3.AXIS_Y * sin(get_polar_angle()) * Vector3.AXIS_X * cos(get_aximuthal_angle())

func get_tension_vector() -> Vector3:
	return self.global_position.direction_to(hook_point.global_position)

func get_pendulum_origin() -> Vector3:
	return hook_point.global_position

func get_pendulum_start_position() -> Vector3:
	return start_position

func get_polar_angle() -> float:
	var tension = get_tension_vector()
	var xzLen = Vector2(tension.x, tension.z).length()
	return atan2(-tension.y, xzLen)
	#return hook_point.global_position.signed_angle_to(-1 * get_tension_vector(), Vector3.UP)

func get_azimuthal_angle() -> float:
	var tension = get_tension_vector()
	return atan2(tension.x, tension.z)
	#return hook_point.global_position.signed_angle_to(get_tension_vector(), Vector3.RIGHT)

func get_pendulum_length() -> float:
	return self.global_position.distance_to(hook_point.global_position)
