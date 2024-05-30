class_name WalkState
extends PlayerState

#func enter(_payload: Dictionary = {}):
	#player.current_speed = player.movement_speed

func handle_input(event):
	if event.is_action_pressed("jump"):
		if player.is_on_floor():
			transition_to.emit(self, "Airborne", { "ground_jump": true })
		else:
			transition_to.emit(self, "Airborne", { "air_jump": true })
	elif not player.is_moving():
		transition_to.emit(self, "Idle")
	elif event.is_action_pressed("sprint"):
		transition_to.emit(self, "Sprint")

func physics_update(delta):
	var speed = player.movement_speed
	
	player.move(delta, speed)
	
	if not player.is_on_floor():
		transition_to.emit(self, "Airborne")
	
	#player.orient_toward(delta, direction)
