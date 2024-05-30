class_name State
extends Node

signal transition_to

@export var available_target_states : Dictionary

func enter(payload: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass

func can_transition_to(target_state_name: String) -> State:
	var node_path = available_target_states.get(target_state_name)
	
	if not node_path:
		return null
	
	var node = get_node(node_path)
	
	if not node:
		return null
		
	return node
