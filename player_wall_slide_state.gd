extends PlayerrrState

@export var wall_speed: SpeedData = SpeedData.new()
@export_range(0.0, 5.0) var hang_time: float

var time_on_wall: float = 0.0

var current_payload: Dictionary

func enter(payload: Dictionary = {}) -> void:
	current_payload = payload
	time_on_wall = 0.0
	player.velocity = Vector3.ZERO

func exit() -> void:
	pass

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		transition_to.emit(self, "WallJumpState", { "wall_normal": player.get_wall_normal() })

func update(delta) -> void:
	pass

func physics_update(delta) -> void:
	if player.is_on_floor():
		transition_to.emit(self, "GroundedState")
		return
	
	if not player.is_on_wall():
		transition_to.emit(self, "AirborneState")
		return
	
	time_on_wall += delta
	
	if time_on_wall < hang_time:
		return
	
	player.velocity.y = move_toward(player.velocity.y, -wall_speed.max_speed, wall_speed.acceleration_rate * delta)



