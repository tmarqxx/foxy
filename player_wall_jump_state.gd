extends PlayerrrState

@export var speed: SpeedData = SpeedData.new()
@export var wall_jump: JumpData = JumpData.new()

var basic_jump: JumpData = preload("res://PlayerGroundJumpResource.tres")

var jump_time: float = 0.0
var jump_direction: Vector3 = Vector3.ZERO

var is_air_jump_buffered: bool = false

var current_payload: Dictionary

func enter(payload: Dictionary = {}):
	current_payload = payload
	
	jump_time = 0.0
	jump_direction = payload.get("wall_normal")
	is_air_jump_buffered = false
	
	player.velocity.y = wall_jump.velocity

func exit():
	pass

func handle_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		is_air_jump_buffered = true

func update(delta):
	pass

func physics_update(delta) -> void:
	if player.is_on_floor():
		transition_to.emit(self, "GroundedState")
	
	jump_time += delta
	
	if jump_time > wall_jump.time_to_peak:
		transition_to.emit(self, "AirborneState", { "air_jump": is_air_jump_buffered })
		return
	
	player.velocity.y += wall_jump.gravity * delta
	
	player.velocity.x = jump_direction.x * speed.max_speed
	player.velocity.z = jump_direction.z * speed.max_speed
	
	player.look_toward(jump_direction, 1.0)
	

