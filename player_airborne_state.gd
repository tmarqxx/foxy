extends PlayerrrState

@export var air_speed: SpeedData = SpeedData.new()
@export var ground_jump: JumpData = JumpData.new()
@export var air_jump: JumpData = JumpData.new()
@export var coyote_time_limit: float = 0.1
var double_jump: JumpData = JumpData.new()

@export var jump_curve = Curve.new()

@onready var spire_jump_component: SpireJumpComponent = %SpireJumpComponent

var target_jump_height: Vector3 = Vector3.ZERO
var entered_at: float

var coyote_time: float = 0.0

var jump_time: float = 0.0
var jump_initial_position: Vector3
var jump_peak_time: float = 0.0
var jump_direction: Vector3 = Vector3.ZERO

var camera_offset: Vector3 = Vector3.ZERO

var air_velocity: Vector3 = Vector3.ZERO
var jump_gravity: float = ground_jump.gravity

var is_ground_jump_buffered: bool = false
var is_air_jump_buffered: bool = false
var is_jump_buffered: bool = false
var is_air_jump_available: bool = true

var current_payload: Dictionary

func enter(payload: Dictionary = {}):
	is_air_jump_buffered = false
	spire_jump_component.set_enabled(true)
	
	if payload.get("ground_jump") == true:
		print("GROUND_JUMP")
		is_ground_jump_buffered = false
		is_air_jump_available = true
		jump_initial_position = player.position
		camera_offset = player.position
		jump_direction = Vector3.ZERO

		jump_gravity = ground_jump.gravity
		jump_peak_time = ground_jump.time_to_peak
		jump_time = 0.0
		
		player.velocity.y = ground_jump.velocity
	elif payload.get("air_jump") == true and is_air_jump_available:
		print("AIR_JUMP")
		is_air_jump_available = false
		jump_direction = Vector3.ZERO
		
		#if current_payload.get("ground_jump") == true and player.velocity.y > -1.0:
			#dbl_jump = JumpData.new()
			#dbl_jump.time_to_peak = ground_jump.time_to_peak + air_jump.time_to_peak - jump_time
			#dbl_jump.height = jump_initial_position.y + ground_jump.height + air_jump.height - player.position.y
			#
			#jump_gravity = dbl_jump.gravity
			#jump_peak_time = dbl_jump.time_to_peak
			#player.velocity.y = dbl_jump.velocity
		#elif player:
		jump_gravity = air_jump.gravity
		jump_peak_time = air_jump.time_to_peak
		jump_time = 0.0
		
		player.velocity.y = air_jump.velocity
	elif payload.get("double_jump") == true and is_air_jump_available:
		is_air_jump_available = false
		jump_direction = Vector3.ZERO
		
		
		double_jump = JumpData.new()
		double_jump.time_to_peak = ground_jump.time_to_peak + air_jump.time_to_peak - jump_time
		double_jump.height = jump_initial_position.y + ground_jump.height + air_jump.height - player.position.y
		
		jump_gravity = double_jump.gravity
		jump_peak_time = double_jump.time_to_peak
		jump_time = 0.0
		
		player.velocity.y = double_jump.velocity
	elif payload.get("trampoline_jump") == true:
		is_air_jump_available = true
		is_air_jump_buffered = false
		player.velocity.y = ground_jump.velocity * payload.get("bounciness")
		player.velocity.x = 0
		player.velocity.z = 0
		
		is_air_jump_available = true
		
		jump_gravity = ground_jump.gravity
		jump_peak_time = ground_jump.time_to_peak
		jump_time = 0.0
		#player.follow_camera.follow_offset.y = 0
		jump_initial_position = player.position + Vector3.UP * 500
	else:
		jump_time = 0.0
		jump_peak_time = 0.0
	
	if payload.get("allow_coyote_time") == true:
		coyote_time = 0.0
	
	current_payload = payload

func exit():
	jump_direction = Vector3.ZERO
	jump_peak_time = 0.0
	spire_jump_component.set_enabled(false)


func handle_input(event: InputEvent):
	if event.is_action_pressed("jump") and not player.is_on_floor():
		if coyote_time < coyote_time_limit:
			enter({ "ground_jump": true })
		elif player.floor_raycast.is_colliding():
			is_ground_jump_buffered = true
		else:
			is_air_jump_buffered = true
	
	if event.is_action_pressed("climb"):
		var target: SpireJumpTarget = spire_jump_component.request_target()

		if target == null:
			return
		
		transition_to.emit(self, "SpireJumpState", { "target": target })


func update(delta):
	pass

func physics_update(delta) -> void:
	if player.is_on_trampoline():
		#print("BOUNCINESS", player.get_trampoline_collider().bounciness )
		enter({ "trampoline_jump": true, "bounciness": player.get_trampoline_collider().bounciness })
		return
	
	if player.is_on_floor():
		if is_ground_jump_buffered:
			enter({ "ground_jump": true })
			return
		
		is_air_jump_available = true
		transition_to.emit(self, "GroundedState")
		return
	
	var direction = player.get_movement_direction()
	spire_jump_component.set_target_direction(player.velocity)
	
	if player.is_on_wall_only() and player.get_wall_normal().dot(direction) < -0.5:
		transition_to.emit(self, "WallSlideState")
		return
		
	
	jump_time += delta
	coyote_time += delta
	
	player.velocity.y += _get_gravity() * delta
	
	if player.position.y > jump_initial_position.y:
		player.follow_camera.follow_offset.y = jump_initial_position.y - player.position.y
	else:
		player.follow_camera.follow_offset.y = 0
	
	if is_air_jump_buffered:
		if player.velocity.y < -1.0:
			enter({ "air_jump": true })
			return
		elif current_payload.get("ground_jump") == true:
			enter({ "double_jump": true })
			return
	
	_apply_input_direction(delta)
	_apply_air_velocity(delta)
	_apply_air_acceleration(delta)
	
	
	#player.apply_acceleration(direction, air_speed.acceleration_rate, air_speed.deceleration_rate, air_speed.max_speed, delta)

func _apply_input_direction(_delta: float) -> void:
	var direction = player.get_movement_direction()

	if jump_time < (jump_peak_time / 3) and player.is_moving() and not jump_direction.length() > player.input_deadzone:
		jump_direction = direction

func _apply_air_velocity(delta: float) -> void:
	if current_payload.get("trampoline_jump") == true:
		return
	
	if jump_time < (jump_peak_time / 2) and jump_direction.length() > player.input_deadzone:
		player.velocity.x = jump_direction.x * air_speed.max_speed
		player.velocity.z = jump_direction.z * air_speed.max_speed

func _apply_air_acceleration(delta: float) -> void:
	var direction = player.get_movement_direction()
	
	if jump_time < jump_peak_time / 2:
		return
	
	var lateral_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	
	if not player.is_moving() and jump_time > jump_peak_time:
		player.velocity = player.accelerate_toward(player.velocity, Vector3.ZERO, air_speed.deceleration_rate * delta)
	elif player.is_moving() and direction.dot(lateral_velocity) >= 0.0:
		player.velocity = player.accelerate_toward(player.velocity, direction * air_speed.max_speed, air_speed.acceleration_rate * delta)
		player.look_toward(player.velocity, 20 * delta)
	elif player.is_moving() and direction.dot(lateral_velocity) < 0.0:
		var acceleration = air_speed.acceleration_rate
		if player.velocity.y < -10.0:
			acceleration *= 4
		
		player.velocity = player.accelerate_toward(player.velocity, direction * air_speed.max_speed, 4 * acceleration * delta)
	
func _get_gravity() -> float:
	if player.velocity.y > 0.0:
		return jump_gravity
	else:
		return ground_jump.fall_gravity
