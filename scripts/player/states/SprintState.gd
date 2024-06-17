class_name SprintState
extends PlayerState

func enter(_payload: Dictionary = {}):
	player.camera.release_platform_snap()

func handle_input(event):
	if event.is_action_pressed("jump") and player.is_on_floor():
		transition_to.emit(self, "Airborne", { "ground_jump": true })
	elif not player.is_moving():
		transition_to.emit(self, "Idle")
	elif Input.is_action_just_released("sprint"):
		transition_to.emit(self, "Walk")

func physics_update(delta):
	var speed = player.movement_speed * player.sprint_speed
	
	#player.orient_toward(delta, direction)
	player.move(delta, speed)
	
	if not player.is_on_floor():
		transition_to.emit(self, "Airborne")
