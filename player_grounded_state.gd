extends PlayerrrState

@export var ground_speed: SpeedData = SpeedData.new()

var lateral_damping_value := 0.1

var current_payload: Dictionary

func enter(payload: Dictionary = {}):
	current_payload = payload
	player.is_gravity_enabled = false
	player.follow_camera.follow_offset.y = 0

func exit():
	pass

func handle_input(event: InputEvent):
	if event.is_action_pressed("jump") and player.is_on_floor():
		transition_to.emit(self, "AirborneState", { "ground_jump": true })

func update(_delta):
	pass

func physics_update(delta):
	if not player.is_on_floor():
		transition_to.emit(self, "AirborneState", { "allow_coyote_time": true })
		return
	
	if player.is_on_trampoline():
		#print("BOUNCINESS", player.get_trampoline_collider().bounciness )
		transition_to.emit(self, "AirborneState", { "trampoline_jump": true, "bounciness": player.get_trampoline_collider().bounciness })
		return
	
	var direction = player.get_movement_direction()
	
	#if abs(ground_speed.max_speed - player.velocity.length()) >  ground_speed.max_speed:
	#print("VEL RATIO: ", player.velocity.length() / ground_speed.max_speed)
	#var extra_dampness_value = (1 - clamp(player.velocity.length() / ground_speed.max_speed, 0.0, 1.0)) * 0.9
	#print("DAMP RATIO: ", dampness_value + extra_dampness_value)
	#player.set_camera_damping(Vector3(dampness_value + extra_dampness_value, 0, dampness_value + extra_dampness_value))
	#else:
		#player.set_camera_damping(DAMPING_WHILE_MOVING)
	
	
	player.look_toward(direction, 50 * delta)
	
	if player.is_moving():
		player.velocity = player.accelerate_toward(player.velocity, direction * ground_speed.max_speed, ground_speed.acceleration_rate * delta)
		lateral_damping_value -= 2 * delta
	else:
		player.velocity = player.accelerate_toward(player.velocity, direction * ground_speed.max_speed, ground_speed.deceleration_rate * delta)
		lateral_damping_value += 4 * delta
	
	
	#player.apply_acceleration(direction, ground_speed.acceleration_rate, ground_speed.deceleration_rate, ground_speed.max_speed, delta)
	#lateral_damping_value = clamp(lateral_damping_value, 0.15, 1.0)
	#
	#player.follow_camera.follow_damping_value.x = lateral_damping_value
	#player.follow_camera.follow_damping_value.z = lateral_damping_value
	
	
