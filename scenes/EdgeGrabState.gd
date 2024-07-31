extends PlayerState

var current_payload: Dictionary

func enter(payload: Dictionary = {}):
	current_payload = payload
	player.camera.release_platform_snap()
	player.skin.edge_grab()
	player.velocity = Vector3.ZERO

func exit():
	pass

func handle_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		transition_to.emit(self, "Airborne", { "ledge_jump": true })

func update(delta):
	pass

func physics_update(delta):
	var wall_normal = current_payload.get("wall_normal")
	player.orient_toward(delta, -wall_normal)
	
	if player.get_movement_direction().dot(wall_normal) > 0.75:
		transition_to.emit(self, "Airborne")
	

