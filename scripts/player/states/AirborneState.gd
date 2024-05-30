class_name AirborneState
extends PlayerState

@export var grappling_hook : GrapplingHook

var _is_air_jump_available : bool = true

const PLATFORM_SNAP_RELEASE_THRESHOLD : float = 6.0

func enter(payload: Dictionary = {}):
	#player.camera.disable_lerp()
	player.camera.lock_platform_snap()
	
	if payload.has("ground_jump"):
		player.velocity.y = player.jump_velocity
	elif payload.has("air_jump") and _is_air_jump_available:
		_is_air_jump_available = false
		player.velocity.y = player.jump_velocity

func handle_input(event):
	if event.is_action_pressed("jump") and _is_air_jump_available:
		enter({ "air_jump": true })
	
	if event.is_action_pressed("grapple"):
		grappling_hook.throw_hook()

func update(delta):
	var diff = abs(player.global_position.y - player.camera.platform_snap_target.y)
	
	if diff > PLATFORM_SNAP_RELEASE_THRESHOLD:
		player.camera.release_platform_snap()
	
	if player.is_on_floor():
		if player.is_sprinting():
			transition_to.emit(self, "Sprint")
		elif player.is_moving():
			transition_to.emit(self, "Walk")
		else:
			transition_to.emit(self, "Idle")

func physics_update(delta):
	player.velocity.y += player.get_gravity() * delta
	player.velocity.y = clamp(player.velocity.y, -player.maximum_falling_speed, 10000)
	
	var speed = player.movement_speed
	
	#player.orient_toward(delta, direction)
	player.move(delta, speed)

func exit():
	#player.camera.enable_lerp()
	player.camera.release_platform_snap()
	_is_air_jump_available = true

func _handle_hook_engaged():
	transition_to.emit(self, "GrappleSwing")
