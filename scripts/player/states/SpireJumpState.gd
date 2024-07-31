extends PlayerState

@onready var path : Path3D = $Path3D
@onready var path_follow : PathFollow3D = $Path3D/PathFollow3D
@onready var remote_transform : RemoteTransform3D = $Path3D/PathFollow3D/RemoteTransform3D


const PLATFORM_SNAP_RELEASE_THRESHOLD : float = 6.0

var initial_position : Vector3
var target_position : Vector3

var jump_curve : Curve3D


var gravity : float
var velocity : Vector3

var time : float = 0.0
var time_to_perch : float = 1.5

var _payload : Dictionary

func enter(payload: Dictionary = {}):
	_payload = payload
	initial_position = player.global_position
	player.skin.flip()
	
	#if payload.has("to_tightrope"):
		#var tightrope_node = payload.get("tightrope_node")
		#tightrope_node.set_path_progress_from_position(payload.get("target"))
		#target_position = tightrope_node.path_follow.global_position
	#else:
	target_position = payload.get("target")
	target_position.y += 1.0
	
	player.velocity.y /= 4
	
	if initial_position.y < target_position.y:
		player.velocity.y = player.jump_velocity / 4
		player.camera.relock_platform_snap()
	
	player.velocity.y += player.jump_velocity
	#path.set_as_top_level(true)
	#player.camera.lock_platform_snap()
	#
	#target_position = payload.get("target")
	#target_position.y += 1.0
	#
	#path.curve.clear_points()
	#path_follow.set_progress(0.0)
	#
	#var start_position = player.global_position
	#var peak_position = start_position
	#peak_position.y = max(target_position.y + 0.75, start_position.y + 0.5)
	#
	#var distance = start_position.distance_to(target_position)
	#var direction = start_position.direction_to(target_position)
	#
	#peak_position.x += direction.x * distance / 2
	#peak_position.z += direction.z * distance / 2
	#
	#var start_to_target = start_position.direction_to(target_position)
	#var start_to_peak = start_position.direction_to(peak_position)
	#var peak_to_target = peak_position.direction_to(target_position)
	#
	#if not start_position.y > peak_position.y:
		#path.curve.add_point(start_position, Vector3.DOWN, start_to_peak)
		##jump_curve.add_point(peak_position)
		#path.curve.add_point(peak_position, Vector3(-start_to_peak.x, 0.0, -start_to_peak.z), Vector3(peak_to_target.x, 0.0, peak_to_target.z) * player.movement_speed / 4)
		##jump_curve.add_point(peak_position, Vector3(-start_to_peak.x, 0, -start_to_peak.z), Vector3(peak_to_target.x, 0.0, peak_to_target.z))
		#path.curve.add_point(target_position, Vector3.UP, Vector3.DOWN)
	#else:
		#path.curve.add_point(start_position, Vector3.DOWN, Vector3(start_to_target.x, 0.0, start_to_target.z) * player.movement_speed / 2)
		#path.curve.add_point(target_position, Vector3.UP, Vector3.DOWN)
	#
	#var lateral_direction = start_to_target * distance
	#if start_position.y > target_position.y:
		#lateral_direction.y = 0
	#speed = player.movement_speed * lateral_direction.length() / 6
	
	
	#speed = clamp(speed, 0.0, player.movement_speed * 2.2)
	
	#tessellated_points = jump_curve.tessellate()
	#remote_transform.set_remote_node(player.get_path())
	
	#print(tessellated_points)
	

	#var diff = target_position - player.global_position
	#var diffXZ = Vector3(diff.x, 0.0, diff.z)
	#var lateral_distance = diffXZ.length()
	#
	#var lateral_speed = player.movement_speed
	#time = 1.4
	#velocity = diffXZ.normalized() * lateral_speed
	#
	#var a = player.global_position.y
	#var b = 4.0
	#var c = target_position.y
	#
	#gravity = -4*(a - 2*b + c) / (time * time)
	#velocity.y = -(3*a - 4*b + c) / time

var speed : float = 0.0
var acceleration : float = 6.0

var current_descent : float = 0.0
var descent_ratio : float = 0.0
var full_descent : float = 0.0
var final_descent : float = 0.0
var initial_descent_position : Vector3 = Vector3.ZERO

var is_descending : bool = false

func physics_update(delta):
	var distance = player.global_position.distance_to(target_position)
	var direction = player.global_position.direction_to(target_position)
	
	#print(player.velocity.y)
	if player.velocity.y < 0.0:
		is_descending = true
	
	player.velocity.y += player.get_gravity() * delta
	player.velocity.y = clamp(player.velocity.y, -player.maximum_falling_speed, 10000)
	
	player.velocity.x = direction.x * player.movement_speed * 1.2
	player.velocity.z = direction.z * player.movement_speed * 1.2
	
	player.move_and_slide()
	player.orient_toward(delta, direction)
	
	if is_descending:
		player.global_position.y = clamp(player.global_position.y, target_position.y, target_position.y + 10)
	
	if player.global_position.y == target_position.y:
		player.global_position.x = target_position.x
		player.global_position.z = target_position.z
		if _payload.has("to_tightrope"):
			transition_to.emit(self, "TightropeWalk", {
				"tightrope_node": _payload.get("tightrope_node"),
				"initial_position": _payload.get("target")
			})
		else:
			transition_to.emit(self, "SpirePerch")
		
	
	
	
	#-------------------------
	#print("path_follow.position", path_follow.position)
	
	#if path_follow.progress >= path.curve.get_baked_length():
		#transition_to.emit(self, "SpirePerch")
		#return
	#
	#if path_follow.progress_ratio < 0.5:
		#speed += player.movement_speed * 6 * delta
	#else:
		#speed -= player.movement_speed * 2 * delta
		#speed = clamp(speed, player.movement_speed, player.movement_speed * 4)
	
	#path_follow.progress += speed * delta
	#player.global_position = path_follow.global_position
	#--------------------------
	#player.global_position = new_position
	#
	#player.velocity = velocity
	#velocity.y -= clamp(gravity * delta, -player.maximum_falling_speed, 1000)
	#
	#player.orient_toward(delta, player.global_position.direction_to(target_position))
	#player.move_and_slide()
	#
	#time -= delta
	#
	#if time < 0.0:
		#print("SPIRE PERCH!!")
		#player.velocity = Vector3.ZERO
		#transition_to.emit(self, "SpirePerch")

func exit():
	path.set_as_top_level(false)
	is_descending = false
	#path.curve.clear_points()
	#path_follow.set_progress(0.0)
	time = 0.0
	speed = 0.0
	#player.camera.release_platform_snap()
	#tessellated_points = []
	#jump_curve.clear_points()
	#path.set_curve(null)
