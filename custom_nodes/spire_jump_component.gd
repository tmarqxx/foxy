@tool
extends Node3D
class_name SpireJumpComponent

@export var collision_buffer_time: float

@export var enabled: bool = false:
	set = set_enabled
@export var surrounding_cast: ShapeCast3D
@export var directional_cast: ShapeCast3D
@export var fine_cast: ShapeCast3D
@export var blocked_raycast: RayCast3D
@export var target_direction: Vector3 = Vector3.ZERO
@export_range(1.0, 10.0) var radius: float = 1.0

func _ready() -> void:
	set_enabled(false)
	surrounding_cast.set_max_results(3)
	directional_cast.set_max_results(3)
	fine_cast.set_max_results(3)


func request_target() -> SpireJumpTarget:
	var target: SpireJumpTarget = null
	
	if _has_target(fine_cast):
		target = _get_target(fine_cast)
	elif _has_target(directional_cast):
		target = _get_target(directional_cast)
	elif _has_target(surrounding_cast):
		target = _get_target(surrounding_cast)
	
	#if target_cache.has(fine_cast.get_instance_id()):
		#target = target_cache.get(fine_cast.get_instance_id()).get("collider")
	#elif target_cache.has(directional_cast.get_instance_id()):
		#target = target_cache.get(directional_cast.get_instance_id()).get("collider")
	#elif target_cache.has(surrounding_cast.get_instance_id()):
		#target = target_cache.get(surrounding_cast.get_instance_id()).get("collider")
	
	if _is_blocked(target):
		return null
	
	return target

func set_enabled(value: bool) -> void:
	enabled = value
	
	fine_cast.set_enabled(enabled)
	surrounding_cast.set_enabled(enabled)
	directional_cast.set_enabled(enabled)
	blocked_raycast.set_enabled(enabled)

func set_target_direction(value: Vector3) -> void:
	target_direction = Vector3(value.x, 0, value.z).normalized()
	directional_cast.position.x = target_direction.x * abs(radius - directional_cast.shape.radius)
	directional_cast.position.z = target_direction.z * abs(radius - directional_cast.shape.radius)
	fine_cast.target_position = target_direction * abs(radius - fine_cast.shape.radius)

func _has_target(cast: ShapeCast3D) -> bool:
	if not enabled:
		return false
	
	cast.force_shapecast_update()
	
	return cast.is_colliding()

func _get_target(cast: ShapeCast3D) -> SpireJumpTarget:
	if not _has_target(cast):
		return null
		
	var collider = cast.get_collider(0)
	
	if collider.is_in_group("SpirePerchTarget"):
		return SpireJumpTarget.new(collider.global_position, collider)
	elif collider.is_in_group("TightRopeTarget"):
		return SpireJumpTarget.new(cast.get_collision_point(0), collider)
	
	return null

func _is_blocked(target: SpireJumpTarget) -> bool:
	if target == null:
		return false
	
	blocked_raycast.target_position = target.position - global_position
	
	blocked_raycast.force_raycast_update()
	
	if not blocked_raycast.is_colliding():
		return false
	
	var blocking_collider = blocked_raycast.get_collider()
	
	return blocking_collider.get_instance_id() != target.node.get_instance_id()
