extends State

var current_payload: Dictionary

func enter(payload: Dictionary = {}) -> void:
	current_payload = payload
	pass

func exit() -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass
