extends PlayerState

var tightrope_node : TightropePath
var progress_scalar : int = 0

func enter(payload: Dictionary = {}):
	player.camera.release_platform_snap()
	#player.velocity = Vector3.ZERO
	tightrope_node = payload.get("tightrope_node")
	tightrope_node.set_path_progress_from_position(payload.get("initial_position"))
	tightrope_node.set_remote_transform_path(player.get_path())
	
	var tightrope_direction = tightrope_node.get_tightrope_direction()
	var progress_scalar = _get_progress_scalar(player.camera.get_forward_vector())
	player.orient_toward(0.05, progress_scalar * tightrope_direction)
	player.set_up_vector(tightrope_node.get_up_vector())

func handle_input(event):
	if event.is_action_pressed("jump"):
		transition_to.emit(self, "Airborne", { "ground_jump": true })

func physics_update(delta):
	if not player.is_moving():
		return
	
	var tightrope_direction = tightrope_node.get_tightrope_direction()
	var progress_scalar = _get_progress_scalar(player.get_movement_direction(), 0.75)
	
	if progress_scalar == 0:
		return
	
	var value = progress_scalar * player.movement_speed * delta
	tightrope_node.update_path_progress(value)
	
	var new_up_vector = tightrope_node.get_up_vector()
	player.orient_toward(delta, progress_scalar * tightrope_direction)
	player.set_up_vector(new_up_vector)

func _get_progress_scalar(direction: Vector3, threshold: float = 0.0) -> int:
	direction.y = 0
	var xz_direction = direction.normalized()
	print("DIRECTION ", xz_direction)
	var tightrope_direction = tightrope_node.get_tightrope_direction()
	tightrope_direction.y = 0
	var xz_tightrope_direction = tightrope_direction.normalized()
	print("TIGHTROPE DIRECTION ", xz_tightrope_direction)
	var dot_product = xz_direction.dot(xz_tightrope_direction)
	print("DOT PRODUCT ", dot_product)
	
	if dot_product > threshold:
		return 1
	elif dot_product < -threshold:
		return -1
	else:
		return 0

func exit():
	player.set_up_vector(Vector3.UP)
	#player.orient_toward(get_physics_process_delta_time(), player.get_movement_direction())
	#player.reset_mesh_basis()
