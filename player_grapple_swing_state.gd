extends PlayerrrState

@export_range(0.0, 5.0) var hang_time: float = 0.0

@onready var grapple_hook_component: GrappleHookComponent = %GrappleHookComponent

var swing_time: float = 0.0
var is_swinging: bool = false

var current_payload: Dictionary
var initial_velocity: Vector3 = Vector3.ZERO

func enter(payload: Dictionary = {}):
	#swinging_node = payload.get("target")
	swing_time = 0.0
	current_payload = payload
	initial_velocity = player.velocity
	initial_velocity.y = clamp(initial_velocity.y, -player.maximum_falling_speed, -player.maximum_falling_speed / 4)
	player.velocity.y = 0
	is_swinging = false
	player.collision_shape.set_disabled(true)
	pass

func exit():
	grapple_hook_component.release_swing()
	player.collision_shape.set_disabled(false)
	is_swinging = false

func handle_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		transition_to.emit(self, "AirborneState", { "ground_jump": true })

func update(delta):
	pass

func physics_update(delta):
	if swing_time < hang_time:
		swing_time += delta
		return
	
	if not is_swinging:
		player.velocity = Vector3.ZERO
		grapple_hook_component.start_swing(initial_velocity)
		is_swinging = true
		return
	
	var swinging_body = grapple_hook_component.get_swinging_body()
	
	if player.is_moving() and swinging_body.linear_velocity.length() < 16.0:
		var tension_vector = grapple_hook_component.get_tension_vector()
		var lateral_tension = Vector3(tension_vector.x, 0, tension_vector.z).normalized()
		#var swing_force = (player.get_movement_direction() + tension_vector).normalized()
		swinging_body.apply_central_impulse(player.get_movement_direction() * max(0.5, tension_vector.y) * 10.0 * delta)
	
	#swinging_body.linear_velocity = swinging_body.linear_velocity.limit_length(18.0)
	print("LIN VEL: ", swinging_body.linear_velocity.length())
	#swinging_body.angular_velocity = swinging_body.angular_velocity.limit_length(3.5)
	#print("ANG VEL: ", swinging_body.angular_velocity.length())
	
	player.global_position = swinging_body.global_position - grapple_hook_component.position

func _get_movement_direction() -> Vector3:
	var input_direction = player.get_input_direction()
	var movement_direction = Vector3(input_direction.x, 0, input_direction.z)

	return movement_direction.rotated(Vector3.UP, grapple_hook_component.get_static_body().rotation.y).normalized()
