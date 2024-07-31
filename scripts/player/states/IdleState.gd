extends PlayerState

func enter(payload: Dictionary = {}):
	player.skin.idle()
	player.camera.release_platform_snap()

func handle_input(event):
	if player.is_on_floor() and event.is_action_pressed("jump"):
		transition_to.emit(self, "Airborne", { "ground_jump": true })
	elif player.is_sprinting():
		transition_to.emit(self, "Sprint")
	elif player.is_moving():
		transition_to.emit(self, "Walk")

func physics_update(delta):
	player.move(delta, 0.0)
	
	if not player.is_on_floor():
		transition_to.emit(self, "Airborne")
	
