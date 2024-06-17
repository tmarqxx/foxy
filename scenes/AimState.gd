extends PlayerState

@export var bow : Bow

var aiming_sensitivity_scale : float = 1.0

var initial_camera_position : Vector3
var is_drawing : bool = false

func enter(payload: Dictionary = {}):
	# set camera offset for over-shoulder position
	player.camera.sensitivity_scale = 0.75
	player.camera.fov = 60.0

func handle_input(event):
	if event.is_action_pressed("aim"):
		transition_to.emit(self, "Look")
	elif event.is_action_pressed("shoot"):
		is_drawing = true
	elif event.is_action_released("shoot"):
		is_drawing = false
		bow.shoot()
		

func physics_update(delta):
	if Input.is_action_pressed("shoot"):
		is_drawing = true
	else:
		is_drawing = false
		
	var offset = Vector3.ZERO
	offset += player.camera.get_right_vector() * 1.5
	offset += player.camera.get_forward_vector() * 2.0
	offset.y -= 0.5
	
	player.camera.subject_offset = offset
	
	var direction = player.global_position.direction_to(player.camera.global_position + player.camera.get_forward_vector() * 600)
	player.orient_toward(delta, direction)

func update(delta):
	if is_drawing:
		bow.draw(delta)


func exit():
	player.camera.sensitivity_scale = 1.0
	player.camera.fov = 75.0
	player.camera.subject_offset = Vector3.ZERO
