extends CharacterBody3D
class_name DynamicCharacterBody3D

# var acceleration: Vector3 = Vector3.ZERO
@export_range(0.0, 1.0) var input_deadzone: float = 0.0

func apply_acceleration(direction: Vector3, acceleration: float, deceleration: float, max_speed: float, delta: float) -> void:
	if direction.length() > input_deadzone and direction.dot(velocity.normalized()) > 0.0:
		#accelerate_toward(direction, acceleration, delta)
		#velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
		velocity.x = move_toward(velocity.x, direction.x * max_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * max_speed, acceleration * delta)
	elif direction.length() > input_deadzone and direction.dot(velocity.normalized()) <= 0.0:
		#velocity = velocity.move_toward(direction * max_speed, deceleration * delta)
		#accelerate_toward(direction, deceleration, delta)
		velocity.x = move_toward(velocity.x, direction.x * max_speed, deceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * max_speed, deceleration * delta)
	else:
		#accelerate_toward(-velocity.normalized(), deceleration, delta)
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, deceleration * delta)
	
	#limit_velocity_length(max_speed)

func accelerate_toward(initial_velocity: Vector3, target_velocity: Vector3, delta: float) -> Vector3:
	initial_velocity.x = move_toward(initial_velocity.x, target_velocity.x, delta)
	initial_velocity.z = move_toward(initial_velocity.z, target_velocity.z, delta)

	return initial_velocity

# func clamp_velocity_length(min_value: float, max_value: float) -> void:
# 	var clamped_length = max(min_value, min(max_value, velocity.length()))
# 	var direction = velocity.normalized()

# 	velocity = direction * clamped_length

func limit_velocity_length(limit: float) -> void:
	if limit < 0.0:
		push_warning("DynrmaicCharacterBody3D.limit_velocity_length - limit parameter only uses values above 0.0")
	
	limit = abs(limit)

	velocity = velocity.normalized() * limit
