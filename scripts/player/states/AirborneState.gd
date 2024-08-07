class_name AirborneState
extends PlayerState

@export var grappling_hook : GrapplingHook
@export var caster : ShapeCast3D

@export var grapple_cast : ShapeCast3D
@export var surrounding_cast : ShapeCast3D
@export var spire_cast : ShapeCast3D
@export var tightrope_cast : ShapeCast3D
@export var tightrope_cast_2 : ShapeCast3D
@export var blocked_cast : RayCast3D

@export var directional_cast_range : float = 6.0

@onready var coyote_timer : Timer = $CoyoteTimer
@onready var jump_buffer_timer : Timer = $JumpBufferTimer
@onready var double_jump_delay_timer : Timer = $DoubleJumpDelayTimer
@onready var climb_buffer_timer : Timer = $ClimbBufferTimer
@onready var wall_jump_delay_timer: Timer = $WallJumpDelayTimer

var is_air_control_disabled: bool = false
var is_jump_buffered : bool = false
var is_double_jump_buffered : bool = false
var is_climb_buffered : bool = false

var _is_air_jump_available : bool = true
var _is_wall_jump_available: bool = true

enum ClimbTarget { SPIRE = 4, TIGHT_ROPE = 8 }

var air_speed : float = 0.0
var double_jump_buffer : float = 0.0

var current_payload : Dictionary
var hang_time: float = -1.0

func enter(payload: Dictionary = {}):
	current_payload = payload
	air_speed = player.movement_speed
	hang_time = -1.0
	player.camera.lock_platform_snap()
	tightrope_cast.set_enabled(true)
	tightrope_cast_2.set_enabled(true)
	spire_cast.set_enabled(true)
	surrounding_cast.set_enabled(true)
	
	if payload.has("reset_double_jump"):
		_is_air_jump_available = true
	
	if payload.has("ground_jump"):
		player.skin.jump()
		#is_jump_buffered = false
		_is_air_jump_available = true
		double_jump_delay_timer.start()
		
		player.velocity.y = player.jump_velocity
		var initial_velocity = payload.get("initial_velocity")
		
		if initial_velocity != null and initial_velocity.y > 0.0:
			player.velocity.y += initial_velocity.y
			var xz_velocity = initial_velocity
			xz_velocity.y = 0
			print("XZ INITIAL VELOCITY ", xz_velocity.length())
			air_speed += xz_velocity.length()
		
	elif payload.has("air_jump") and _is_air_jump_available:
		player.skin.flip()
		_is_air_jump_available = false
		player.velocity.y /= 4
		player.velocity.y += player.jump_velocity * 0.75
		#player.velocity.y = clamp(player.velocity.y, -player.maximum_falling_speed, player.jump_velocity * 1.5)
	elif payload.has("wall_jump") and _is_wall_jump_available:
		player.skin.jump()
		player.velocity.y = player.jump_velocity
		_is_wall_jump_available = false
		is_air_control_disabled = true
		wall_jump_delay_timer.start()
	elif payload.has("ledge_jump"):
		_is_air_jump_available = false
		player.skin.jump()
		player.velocity.y = player.jump_velocity
		wall_jump_delay_timer.start()
	elif payload.has("trampoline_jump"):
		player.skin.jump()
		player.velocity.y = player.jump_velocity * payload.get("bounciness")
		_is_air_jump_available = true
		wall_jump_delay_timer.start()
		player.camera.release_platform_snap()
	else:
		coyote_timer.start()
		player.skin.fall()
		#player.camera.lock_platform_snap()

func handle_input(event):
	_handle_jump(event)
	
	#if not caster.is_colliding():
		#return
	
	#var collider = caster.get_collider(0)
	#print(collider)
	#print(collider.collision_layer)
	
	if event.is_action_pressed("grapple") and grapple_cast.is_colliding():
		grappling_hook.throw_hook()
	#elif event.is_action_pressed("climb"):
		#directional_cast.force_shapecast_update()
		#
		#if not directional_cast.is_colliding():
			#return
			#
		##var target_position : Vector3
		#var directional_collider = directional_cast.get_collider(0)
		#
		#if _is_blocked(directional_collider):
			#return
		#
		#transition_to.emit(self, "SpireJump", { "target": directional_collider.global_position })
	elif event.is_action_pressed("climb"):
		is_climb_buffered = true
		climb_buffer_timer.start()

func _handle_jump(event):
	if not event.is_action_pressed("jump"):
		return
	
	if coyote_timer.time_left > 0.0:
		enter({ "ground_jump": true })
		return
	
	#if _is_wall_jump_available and player.is_on_wall_only():
		#print("WALL JUMP")
		#wall_normal = player.get_wall_normal()
		#print("WALL NORMAL", wall_normal)
		#enter({ "wall_jump": true })
		#return
	
	if not is_air_control_disabled and _is_air_jump_available and not double_jump_delay_timer.time_left > 0.01:
		enter({ "air_jump": true })
	
	#if event.is_action_pressed("jump") and not _is_air_jump_available:
		#is_jump_buffered = true
		#jump_buffer_timer.start()
		#return
	#
	#if not event.is_action_pressed("jump") or not _is_air_jump_available:
		#return
	#
	#if double_jump_buffer_timer.time_left == 0.0:
		#enter({ "air_jump": true })
	#else:
		#is_double_jump_buffered = true
		

func physics_update(delta):
	if player.is_on_edge() and player.get_movement_direction().dot(player.get_wall_normal()) < -0.5 and not wall_jump_delay_timer.time_left > 0.01:
		transition_to.emit(self, "EdgeGrab", { "wall_normal": player.get_wall_normal() })
		return
	
	if player.is_on_wall_surface() and player.get_movement_direction().dot(player.get_wall_normal()) < -0.5 and not wall_jump_delay_timer.time_left > 0.01:
		transition_to.emit(self, "WallSlide", { "wall_normal": player.get_wall_normal() })
		return
	
	if player.is_on_trampoline() and not wall_jump_delay_timer.time_left > 0.01:
		print("BOUNCINESS", player.get_trampoline_collider().bounciness )
		enter({ "trampoline_jump": true, "bounciness": player.get_trampoline_collider().bounciness })
		return
	
	
	if player.is_on_floor():
		#var next_state = "Idle"
		#
		#if player.is_sprinting():
			#next_state = "Sprint"
		#elif player.is_moving():
			#next_state = "Walk"
		
		transition_to.emit(self, "Grounded")
		_is_air_jump_available = true
		_is_wall_jump_available = true
		return
	
	#if player.is_moving():
		#var movement_direction = -player.get_movement_direction()
		#spire_cast.position.x = movement_direction.x * abs(directional_cast_range - spire_cast.shape.radius)
		#spire_cast.position.z = movement_direction.z * abs(directional_cast_range - spire_cast.shape.radius)
		#
		#tightrope_cast.target_position.x = movement_direction.x * abs(directional_cast_range - tightrope_cast.shape.radius)
		#tightrope_cast.target_position.z = movement_direction.z * abs(directional_cast_range - tightrope_cast.shape.radius)
		#
		#tightrope_cast_2.position.x = movement_direction.x * abs(directional_cast_range - tightrope_cast_2.shape.radius)
		#tightrope_cast_2.position.z = movement_direction.z * abs(directional_cast_range - tightrope_cast_2.shape.radius)
	#directional_cast.target_position.y = -6
	
		
	if _handle_spire_jump_action(spire_cast, true):
		return
	elif _handle_spire_jump_action(tightrope_cast, true):
		return
	elif _handle_spire_jump_action(surrounding_cast):
		return
	
	var gravity = player.get_gravity()
	
	if player.velocity.y < 0.0 and player.velocity.y < -1.0:
		gravity *= 0.5
		
	#if player.velocity.y < 0.0 and hang_time < 0.0:
		#hang_time = 0
	#elif player.velocity.y < 0.0:
		#print("HANG TIME: ", hang_time)
		#hang_time += delta
	#
	#if hang_time <= player.jump_hang_time:
		#gravity *= 0.5
	
	player.velocity.y += gravity * delta
	player.velocity.y = clamp(player.velocity.y, -player.maximum_falling_speed, 10000)
	
	if player.velocity.y < -4.0:
		player.skin.fall()
	
	#print("AIR SPEED ", air_speed)
	air_speed = clamp(air_speed * 0.999, player.movement_speed, 10000)
	
	#player.orient_toward(delta, direction)
	var direction: Vector3
	if current_payload.has("wall_jump"):
		direction = current_payload.get("wall_normal")
		air_speed = player.movement_speed * 1.25
		print("DIRECTION:", direction)
	elif not is_air_control_disabled:
		direction = player.get_movement_direction()
	
	player.move(delta, air_speed, direction)

func exit():
	#player.camera.enable_lerp()
	collider_cache.clear()
	tightrope_cast.set_enabled(false)
	tightrope_cast_2.set_enabled(false)
	spire_cast.set_enabled(false)
	surrounding_cast.set_enabled(false)

func _handle_hook_engaged():
	transition_to.emit(self, "GrappleSwing")

var collider_cache : Dictionary = {}

func _handle_climb_check(caster: ShapeCast3D, cacheable: bool = false) -> Object:
		caster.force_shapecast_update()
		
		if not caster.is_colliding():
			if climb_buffer_timer.time_left > 0.0 and cacheable:
				return collider_cache.get(caster.get_instance_id())
			else:
				return null
		
		var collider = caster.get_collider(0)
		
		collider_cache[caster.get_instance_id()] = collider
		climb_buffer_timer.start()
		
		#print("CLIMB COLLIDER: ", collider)
		#print("COLLISION COUNT: ", caster.get_collision_count())
		#print("COLLISION POINT: ", caster.get_collision_point(0))
		#print("COLLIDER POSITION: ", collider.global_position)
		
		return collider

func _handle_spire_jump_action(caster: ShapeCast3D, cacheable: bool = false) -> bool:
	var collider = _handle_climb_check(caster, cacheable)
	
	if collider == null:
		return false
	
	if not is_climb_buffered:
		return false
	
	var payload: Dictionary = {}
	
	if collider.get_collision_layer() == ClimbTarget.TIGHT_ROPE:
		if _is_blocked(caster.get_collision_point(0), collider.get_instance_id()):
			return false
		
		print("COLLISION RESULT:", caster.collision_result)
		
		payload["target"] = caster.get_collision_point(0)
		payload["to_tightrope"] = true
		payload["tightrope_node"] = collider.get_parent()
		
	elif collider.get_collision_layer() == ClimbTarget.SPIRE:
		if _is_blocked(collider.global_position, collider.get_instance_id()):
			return false
		
		payload["target"] = collider.global_position
	
	transition_to.emit(self, "SpireJump", payload)
	is_climb_buffered = false
	
	return true

func _is_blocked(target: Vector3, id: int) -> bool:
	print("BLOCKED_CAST.GLOBAL_POSITION ", blocked_cast.global_position)
	blocked_cast.target_position = target - blocked_cast.global_position
	print("BLOCKED_CAST.TARGET_POSITION ", blocked_cast.target_position)
	blocked_cast.force_raycast_update()
	
	if not blocked_cast.is_colliding():
		print("NOT BLOCKED")
		return false
	
	var blocked_collider = blocked_cast.get_collider()
	
	return blocked_collider.get_instance_id() != id

func _on_coyote_timer_timeout():
	pass

func _on_double_jump_buffer_timer_timeout():
	pass

func _on_climb_buffer_timer_timeout():
	is_climb_buffered = false
	collider_cache.clear()

func _on_wall_jump_delay_timer_timeout():
	is_air_control_disabled = false
