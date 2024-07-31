extends PlayerState

var current_payload: Dictionary

var ground_speed: float = 0.0

func enter(payload: Dictionary = {}):
	current_payload = payload
	player.camera.release_platform_snap()
	
	if player.is_moving():
		player.skin.run()
	else:
		player.skin.idle()

func exit():
	pass

func handle_input(event: InputEvent):
	if player.is_on_floor() and event.is_action_pressed("jump"):
		transition_to.emit(self, "Airborne", { "ground_jump": true })
	elif player.is_sprinting():
		ground_speed = player.movement_speed * player.sprint_speed
		player.skin.run()
	elif player.is_moving():
		ground_speed = player.movement_speed
		player.skin.run()
	else:
		ground_speed = 0.0
		player.skin.idle()

func update(delta):
	pass

func physics_update(delta):
	if not player.is_on_floor():
		transition_to.emit(self, "Airborne")
	
	player.move(delta, ground_speed)

