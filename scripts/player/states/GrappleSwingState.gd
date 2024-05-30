extends PlayerState

@export var grappling_hook : GrapplingHook

var damping : float = 0.995

var radius : float = 0.0
var polar_angle : float = 0.0
var polar_velocity : float = 0.0
var azimuthal_angle : float = 0.0
var azimuthal_velocity : float = 0.0
var direction : Vector3 = Vector3.ZERO

const INITIAL_DUMP_COUNT : float = 3
var dump_count : int = INITIAL_DUMP_COUNT

func enter(payload: Dictionary = {}):
	dump_count = INITIAL_DUMP_COUNT
	player.velocity.y = 0.0
	polar_velocity = 0.0
	azimuthal_velocity = 0.0
	polar_angle = grappling_hook.get_polar_angle()
	azimuthal_angle = grappling_hook.get_azimuthal_angle()
	radius = clamp(grappling_hook.get_pendulum_length(), 1.0, 16.0)
	direction = player.get_previous_movement_direction()

func handle_input(event):
	if event.is_action_pressed("jump"):
		transition_to.emit(self, "Airborne", { "ground_jump": true })
		grappling_hook.release_hook()

func physics_update(delta):
	#ATTEMPT 4
	print("--------------------------------------------|")
	print("POLAR ANGLE: ", polar_angle)
	print("AZIMUTHAL ANGLE: %f\n" % azimuthal_angle)
	var gravity = player.fall_gravity
	#print("GRAVITY: ", gravity)
	var origin = grappling_hook.get_pendulum_origin()
	#print("PENDULUM ORIGIN: ", origin)
	#var radius = grappling_hook.get_pendulum_length()
	#radius = clamp(radius, 1.0, 16.0)
	#print("PENDULUM LENGTH: ", radius)
	#polar_angle = grappling_hook.get_polar_angle()
	#print("POLAR/AZIMUTHAL ANGLE: [%f, %f]" % [polar_angle, azimuthal_angle])
	#print("POLAR/AZIMUTHAL VEL: [%f, %f]" % [rad_to_deg(polar_velocity * delta), rad_to_deg(azimuthal_velocity * delta)])
	
	var tension_vector = grappling_hook.get_tension_vector()
	
	var polar_acceleration = -1 * gravity * sin(polar_angle) / radius
	#if player.is_moving():
		#var parallel_acceleration_vector = Vector3.ZERO
		#parallel_acceleration_vector.x = tension_vector.x
		#parallel_acceleration_vector.z = tension_vector.z
		#polar_acceleration += player.get_movement_direction().normalized().dot(parallel_acceleration_vector.normalized()) * player.movement_speed / radius
	polar_velocity += polar_acceleration * delta
	polar_velocity *= damping
	polar_angle += polar_velocity * delta
	
	var azimuthal_acceleration = tension_vector.dot(player.get_movement_direction().normalized()) * player.movement_speed / radius
	#if player.is_moving():
		#var perpendicular_acceleration_vector = Vector3.ZERO
		#perpendicular_acceleration_vector.x = tension_vector.x
		#perpendicular_acceleration_vector.z = tension_vector.z
		#azimuthal_acceleration += player.get_movement_direction().normalized().dot(perpendicular_acceleration_vector.normalized()) * player.movement_speed / radius
	azimuthal_velocity += azimuthal_acceleration * delta
	azimuthal_velocity *= damping
	azimuthal_angle += azimuthal_velocity * delta
	
	var new_position = origin
	new_position.x += radius * sin(polar_angle)
	new_position.z += radius * sin(polar_angle) * cos(azimuthal_angle)
	#new_position.z = grappling_hook.get_pendulum_start_position().z
	#new_position.z = origin.z - direction.z * radius * cos/(angle)
	new_position.y += radius * cos(polar_angle)
	
	# If initial x component is negative, flip sign of x component
	#if player.global_position.x < 0.0:
		#new_position.x *= -1
	#
	## If signs of initial x and z components match, flip sign of z component
	#if (player.global_position.z < 0.0 and player.global_position.x < 0.0) or (player.global_position.z > 0.0 and player.global_position.z > 0.0):
		#new_position.z *= -1
	
	
	#if dump_count > 0:
		#print(":---------------------------------------------------------------:")
		#print("ORIGIN: ", origin)
		#print("PLAYER/HOOK GLOBAL POSITION: [%v, %v]" % [player.global_position, grappling_hook.global_position])
		#print("POLAR ACCEL/VEL/ANGLE: [%f, %f, %f]" % [polar_acceleration, polar_velocity, polar_angle])
		#print("AZIMUTHAL ACCEL/VEL/ANGLE: [%f, %f, %f]" % [azimuthal_acceleration, azimuthal_velocity, azimuthal_angle])
		#print("NEW POSITION: %v\n" %new_position)
		#dump_count -= 1
	
	#print("NEW POSITION: ", new_position)
	
	#if new_position.y > grappling_hook.hook_point.global_position.y:
		#print("DEBUG??")
	#new_velocity.z = radius * sin(angle) + origin.z
	
	
	player.set_up_vector(tension_vector)
	player.orient_toward(delta, new_position - player.global_position)
	player.global_position = new_position
	# ATTEMPT 3
	#var new_velocity = player.velocity
	#
	#var tension_direction = grappling_hook.get_tension_vector().normalized() * abs(player.get_gravity())
	##print("TENSION VECTOR: ", tension_direction)
	#new_velocity.y += tension_direction.y * delta
	#new_velocity.y -= player.get_gravity() * delta
	#
	#var speed = player.movement_speed
	#var angular_direction = grappling_hook.get_angular_velocity()
	#print("ANGULAR VELOCITY ", angular_direction)
	#new_velocity.x += tension_direction.x * speed * delta
	#new_velocity.z += tension_direction.z * speed * delta
	
	#if player.is_moving():
		#var movement_direction = player.get_movement_direction()
		#new_velocity.x += movement_direction.x * speed * 0.3 * delta
		#new_velocity.y += movement_direction.z * speed * 0.3 * delta
	
	#player.move_and_slide()
	# ATTEMPT 2
	#var new_velocity = player.velocity
	#
	#new_velocity += Vector3.DOWN * player.get_gravity() * delta
	#new_velocity += grappling_hook.get_tension_vector().normalized() * player.get_gravity() * delta
	#
	#var speed = player.movement_speed
	#new_velocity += grappling_hook.get_angular_velocity().normalized() * speed * delta
	#new_velocity += player.get_movement_direction().normalized() * speed * 0.3 * delta
	#
	#
	#player.velocity = new_velocity
	
	# ATTEMPT 1
	#player.velocity.y += player.get_gravity() * delta
	#
	#if not grappling_hook.is_hooked():
		#return
	#
	#var tension_direction = grappling_hook.get_tension_vector().normalized()
	#player.velocity.y += clamp(tension_direction.y * player.get_gravity() * delta, -player.maximum_falling_speed, 1000)
	#
	#var angular_velocity = grappling_hook.get_angular_velocity().normalized() * speed
	#print(angular_velocity)
	#var input_velocity = player.get_movement_direction().normalized() * speed * 0.3
	#print(input_velocity)
	#
	#player.velocity.x += angular_velocity.x * input_velocity.x * delta
	#player.velocity.z += angular_velocity.z * input_velocity.z * delta
	
	#player.move_and_slide()

func exit():
	player.reset_mesh_basis()

func _positive_or_negative_one(x: float) -> float:
	if x < 0.0:
		return -1.0
	
	return 1.0

func _keep_desired_sign(value: float, desired_sign: float, ) -> float:
	if (desired_sign < 0 and value < 0) or (desired_sign > 0 and value > 0):
		return value
	
	return _flip_desired_sign(value, desired_sign)

func _flip_desired_sign(value: float, desired_sign: float) -> float:
	return value * -1
