extends PlayerrrState

@onready var jump: JumpData = preload("res://PlayerGroundJumpResource.tres")
@onready var air_jump: JumpData = preload("res://PlayerAirJumpResource.tres")

@onready var spire_jump_component: SpireJumpComponent = %SpireJumpComponent

var vertical_velocity: float = 0.0
var gravity: float = 0.0
var target: SpireJumpTarget
var initial_position: Vector3
var initial_vertical_diff: float
var initial_lateral_diff: float

var current_payload: Dictionary

func enter(payload: Dictionary = {}):
	target = payload.get("target")
	
	if target.node.is_in_group("SpirePerchTarget"):
		target.node.disabled = false
	elif target.node.is_in_group("TightRopeTarget"):
		target.node.collision_layer += 0x0001
		var tightrope: TightRopePath3D = target.node.get_parent()
		tightrope.set_path_progress_from_position(target.position + player.get_lateral_velocity() * 0.5)
	
	initial_position = player.global_position
	
	initial_vertical_diff = initial_position.y - (target.position.y + jump.height)
	initial_lateral_diff = Vector3(initial_position.x, 0, initial_position.z).distance_to(Vector3(target.position.x, 0, target.position.z))

	#if player.velocity.y < 0:
		#player.velocity.y /= 4
	#if vertical_diff < 0 and player.velocity.y < 0:
		#player.velocity.y /= 4
		#player.velocity.y += abs(vertical_diff) * 2
	if initial_vertical_diff < 0 or (initial_vertical_diff < 0 and initial_lateral_diff > spire_jump_component.radius / 2):
		player.velocity.y = max(2.0, abs(initial_vertical_diff)) * max(4, initial_lateral_diff)
	else:
		player.velocity.y = 1.0
	
	
	if initial_position.y < target.position.y:
		player.velocity.y = 0
	elif initial_position.y < target.position.y + jump.height or player.velocity.y < -5.0:
		player.velocity.y /= 4
	
	print("VEL.Y ", player.velocity.y)
	if player.velocity.y > 0.0:
		player.velocity.y += jump.velocity / 2
	else:
		player.velocity.y += jump.velocity
	
	#player.velocity.x = 0
	#player.velocity.z = 0

	current_payload = payload
	pass

func exit():
	pass

func handle_input(event: InputEvent):
	pass

func update(delta):
	pass

func physics_update(delta):
	var target_position: Vector3

	if target.node.is_in_group("TightRopeTarget"):
		var tightrope: TightRopePath3D = target.node.get_parent()
		if player.is_moving():
			var movement_direction = player.get_movement_direction()
			tightrope.update_path_progress(movement_direction.dot(tightrope.get_tightrope_direction()) * 7.0 * delta)
		target_position = tightrope.get_target_position()
	else:
		target_position = target.position

	if player.is_on_floor():
		if target.node.is_in_group("SpirePerchTarget"):
			transition_to.emit(self, "SpirePerchState", { "spire_node": target.node })
		elif target.node.is_in_group("TightRopeTarget"):
			transition_to.emit(self, "TightRopeWalkState", { "tightrope_node": target.node.get_parent() })
		return
	
	var direction = player.global_position.direction_to(target_position)
	
	#if vertical_velocity > 0.0:
		#vertical_velocity += jump.gravity * delta
	#else:
		#vertical_velocity += jump.fall_gravity * delta
	#print("VERT VEL", vertical_velocity)
	
	#player.global_position.y = clamp(player.global_position.y, target_position.y, 1000)
	
	#if vertical_velocity > 0.0:
		#player.velocity.y += jump.gravity * delta
	#else:
		#player.velocity.y = 0
		#gravity += abs(jump.fall_gravity) * delta
	#player.global_position.y += vertical_velocity

	#player.global_position.y = move_toward(player.global_position.y, target_position.y, vertical_velocity)
	
	#player.velocity = player.accelerate_toward(player.velocity, direction * 7.0, 1.0)
	
	player.velocity.y += _get_gravity() * delta
	player.velocity.x = direction.x * (spire_jump_component.radius + 1) * 2.5
	player.velocity.z = direction.z * (spire_jump_component.radius + 1) * 2.5

	# player.global_position.x = move_toward(player.global_position.x, target_position.x, 7 * delta)
	# player.global_position.z = move_toward(player.global_position.z, target_position.z, 7 * delta)
	
	player.look_toward(direction, 20 * delta)
	
	#player.global_position.y = clamp(player.global_position.y, target_position.y, 1000)
	player.global_position.x = clamp(player.global_position.x, min(player.global_position.x, initial_position.x), max(player.global_position.x, target_position.x))
	player.global_position.z = clamp(player.global_position.z, min(player.global_position.z, initial_position.z), max(player.global_position.z, target_position.z))

func _get_gravity() -> float:
	if player.velocity.y > 0:
		return jump.gravity
	
	return jump.fall_gravity

