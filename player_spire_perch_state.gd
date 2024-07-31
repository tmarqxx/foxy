extends PlayerrrState

var spire_node: Area3D

var current_payload: Dictionary

func enter(payload: Dictionary = {}):
	player.velocity = Vector3.ZERO
	spire_node = payload.get("spire_node")
	current_payload = payload
	player.follow_camera.follow_offset.y = 0
	pass

func exit():
	spire_node.disabled = true

func handle_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		transition_to.emit(self, "AirborneState", { "ground_jump": true })

func update(delta):
	pass

func physics_update(delta):
	player.global_position.x = move_toward(player.global_position.x, spire_node.global_position.x, 2 * delta)
	player.global_position.z = move_toward(player.global_position.z, spire_node.global_position.z, 2 * delta)

