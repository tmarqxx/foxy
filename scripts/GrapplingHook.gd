class_name GrapplingHook
extends Node3D

signal hook_engaged

@export var max_rope_length : float = 16.0
@export_range(0, 10) var time_to_hook : float = 0.0
@export var caster : ShapeCast3D

@onready var timer : Timer = $Timer
#@onready var caster : ShapeCast3D = $ShapeCast3D
@onready var pin_joint : PinJoint3D = $PinJoint3D
@onready var rope_path : Path3D = $RopePath

var hook_point: Node3D = null
var swinging_body : RigidBody3D
var collision_shape : CollisionShape3D

var _is_hooked : bool = false
var tension_vector : Vector3 = Vector3.ZERO
var pendulum_angle : float = 0.0
var start_position : Vector3 = Vector3.ZERO

func _ready():
	rope_path.curve.clear_points()
	swinging_body = $SwingingBody
	swinging_body.set_freeze_enabled(true)
	
	collision_shape = $SwingingBody/CollisionShape3D
	collision_shape.set_disabled(true)

func throw_hook() -> bool:
	#print("IS COLLIDING: ", caster.is_colliding())
	#if not caster.is_colliding():
		#return false
	
	hook_point = caster.get_collider(0)
	print(hook_point.global_position)
	timer.start()
	print("TIMER START")
	return true
	# trigger animation

func _engage_hook():
	hook_engaged.emit()
	_is_hooked = true
	
	rope_path.curve.add_point(hook_point.get_static_body().global_position)
	rope_path.curve.add_point(swinging_body.global_position)
	
	pin_joint.set_global_position(hook_point.get_static_body().global_position)
	pin_joint.set_node_a(hook_point.get_static_body().get_path())
	pin_joint.set_node_b(swinging_body.get_path())
	
	#swinging_body.set_position(Vector3.ZERO)
	swinging_body.set_as_top_level(true)
	swinging_body.set_freeze_enabled(false)
	
	collision_shape.set_disabled(false)

func release_hook():
	_is_hooked = false
	
	rope_path.curve.clear_points()
	
	collision_shape.set_disabled(true)
	
	swinging_body.set_freeze_enabled(true)
	swinging_body.set_as_top_level(false)
	#swinging_body.set_position(Vector3.ZERO)
	
	pin_joint.set_position(Vector3.ZERO)
	pin_joint.set_node_a(NodePath(""))
	pin_joint.set_node_b(NodePath(""))
	

func _physics_process(delta):
	if not is_hooked():
		return
	
	rope_path.curve.set_point_position(1, swinging_body.global_position)

func is_hooked():
	return _is_hooked

func get_tension_vector() -> Vector3:
	return swinging_body.global_position.direction_to(hook_point.get_static_body().global_position)

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
	return swinging_body.global_position.distance_to(hook_point.get_static_body().global_position)

func get_swinging_body() -> RigidBody3D:
	return swinging_body
