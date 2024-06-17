extends PlayerState

func handle_input(event):
	if event.is_action_pressed("aim"):
		transition_to.emit(self, "Aim")
