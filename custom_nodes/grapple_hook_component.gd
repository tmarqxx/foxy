@tool
extends Node3D
class_name GrappleHookComponent

@export var enabled: bool = false:
	set = set_enabled
@export var surrounding_swing_cast: ShapeCast3D
@export var directional_swing_cast: ShapeCast3D
@export var pin_joint: PinJoint3D
@export var swinging_body: RigidBody3D
@export var blocked_raycast: RayCast3D

@export var target_direction: Vector3 = Vector3.ZERO
@export var radius: float = 12.0

var static_target: StaticBody3D

func _ready() -> void:
	surrounding_swing_cast.shape.radius = radius
	directional_swing_cast.shape.radius = radius / 2
	directional_swing_cast.shape.height = radius * 2
	
	pin_joint.set_node_b(swinging_body.get_path())
	_reset_swinging_body()

func can_swing() -> bool:
	if _has_target(directional_swing_cast):
		static_target = _get_target(directional_swing_cast)
	elif _has_target(surrounding_swing_cast):
		static_target = _get_target(surrounding_swing_cast)
	
	return static_target != null

func start_swing(impulse: Vector3) -> void:
	if static_target == null:
		return
	
	_reset_swinging_body()
	
	pin_joint.set_global_position(static_target.global_position)
	pin_joint.set_node_a(static_target.get_path())
	
	_enable_swinging_body()
	swinging_body.apply_central_impulse(impulse)

func release_swing() -> void:
	_reset_swinging_body()
	
	pin_joint.set_node_a(NodePath(""))
	static_target = null

func set_target_direction(value: Vector3) -> void:
	target_direction = Vector3(value.x, 0, value.z).normalized()
	directional_swing_cast.position.x = target_direction.x * (radius / 2)
	directional_swing_cast.position.z = target_direction.z * (radius / 2)

func set_enabled(value: bool) -> void:
	enabled = value
	
	surrounding_swing_cast.set_enabled(enabled)
	directional_swing_cast.set_enabled(enabled)

func get_static_body() -> StaticBody3D:
	return static_target

func get_swinging_body() -> RigidBody3D:
	return swinging_body

func get_tension_vector() -> Vector3:
	var tension_vector: Vector3 = Vector3.ZERO
	
	if static_target != null:
		tension_vector = swinging_body.global_position.direction_to(static_target.global_position)
	
	return tension_vector

func _enable_swinging_body() -> void:
	swinging_body.set_freeze_enabled(false)
	swinging_body.set_as_top_level(true)

func _reset_swinging_body() -> void:
	swinging_body.set_freeze_enabled(true)
	swinging_body.set_as_top_level(false)
	
	swinging_body.linear_velocity = Vector3.ZERO
	swinging_body.angular_velocity = Vector3.ZERO
	swinging_body.transform = Transform3D.IDENTITY

func _has_target(cast: ShapeCast3D) -> bool:
	if not enabled:
		return false
	
	cast.force_shapecast_update()
	
	var is_colliding := cast.is_colliding()
	
	if not is_colliding:
		return false
	
	var collider := cast.get_collider(0)
	var is_blocked := _is_blocked(collider)
	
	if is_blocked:
		return false
	
	return true

func _get_target(cast: ShapeCast3D) -> StaticBody3D:
	if not _has_target(cast):
		return null
	
	return cast.get_collider(0)


func _is_blocked(target: StaticBody3D) -> bool:
	if target == null:
		return false
	
	blocked_raycast.target_position = target.global_position - global_position
	
	blocked_raycast.force_raycast_update()
	
	if not blocked_raycast.is_colliding():
		return false
	
	var blocking_collider = blocked_raycast.get_collider()
	
	return blocking_collider.get_instance_id() != target.get_instance_id()
