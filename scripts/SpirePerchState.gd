extends PlayerState

func enter(payload: Dictionary = {}):
	player.skin.idle()
	player.camera.release_platform_snap()
	player.velocity = Vector3.ZERO

func handle_input(event):
	if event.is_action_pressed("jump"):
		transition_to.emit(self, "Airborne", { "ground_jump": true })
