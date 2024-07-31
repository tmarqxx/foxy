extends PlayerState

@export_range(0.0, 5.0) var HANG_TIME: float = 0.25
@export_range(0.0, 10.0) var SLIDE_TIME: float = 3.0

var _hang_timer: float
var _slide_timer: float
var current_payload: Dictionary

func enter(payload: Dictionary = {}):
	current_payload = payload
	player.skin.wall_slide()
	player.velocity = Vector3.ZERO
	_hang_timer = HANG_TIME
	_slide_timer = SLIDE_TIME

func handle_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		transition_to.emit(self, "Airborne", { "wall_jump": true, "wall_normal": player.get_wall_normal() })

func physics_update(delta: float):
	var wall_normal = current_payload.get("wall_normal")
	player.orient_toward(delta, -wall_normal)
	
	if player.is_on_floor():
		transition_to.emit(self, "Grounded")
		return
	elif not player.is_on_wall_surface() and not player.is_on_floor() or player.get_movement_direction().dot(wall_normal) > 0.75:
		transition_to.emit(self, "Airborne")
		return
	
	
	if _hang_timer < 0:
		player.velocity.y += player.fall_gravity * 0.5 * delta
		player.velocity.y = clamp(player.velocity.y, -player.maximum_falling_speed / 4, 1000)
		_slide_timer -= delta
	else:
		_hang_timer -= delta
		player.velocity = Vector3.ZERO
	
	player.move_and_slide()
