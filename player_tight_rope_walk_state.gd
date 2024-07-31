extends PlayerrrState

var tightrope_node: TightRopePath3D
var velocity: float = 0.0

var current_payload: Dictionary

func enter(payload: Dictionary = {}):
	tightrope_node = payload.get("tightrope_node")
	tightrope_node.polygon.collision_layer -= 0x0001
	player.velocity = Vector3.ZERO
	player.follow_camera.follow_offset.y = 0
	current_payload = payload
	pass

func exit():
	tightrope_node.reset()

func handle_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		transition_to.emit(self, "AirborneState", { "ground_jump": true })

func update(delta):
	pass

func physics_update(delta):
	var direction = player.get_movement_direction()
	tightrope_node.update_path_progress(sign(direction.dot(tightrope_node.get_tightrope_direction())) * 7.0 * delta)
	
	#player.velocity.move_toward(player.global_position.direction_to(tightrope_node.get_target_position()) * 7.0, 1.0)
	#player.velocity = tightrope_node.get_target_position() - player.global_position
	var next_position = tightrope_node.get_target_position()
	player.look_toward(player.global_position.direction_to(next_position), 1.0)
	player.global_position = next_position

