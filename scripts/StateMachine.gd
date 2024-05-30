class_name StateMachine
extends Node

var states : Dictionary = {}
@export var initial_state : State
var current_state : State

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_children():
		if node is State:
			states[node.name.to_lower()] = node
			node.connect("transition_to", _handle_transition_to)
	assert(initial_state != null)
	
	current_state = initial_state
	current_state.enter()

func _input(event):
	current_state.handle_input(event)

func _process(delta):
	current_state.update(delta)

func _physics_process(delta):
	current_state.physics_update(delta)

#func transition_to(target_state_name: String, payload: Dictionary = {}):
	#var next_state = current_state.can_transition_to(target_state_name)
	#
	#if not next_state:
		#print("Invalid transition_to call - cannot transition from %s state to %s state" % [current_state.name, target_state_name])
		#return
	#
	#current_state.exit()
	#next_state.enter(payload)
	#
	#current_state = next_state

func _handle_transition_to(source_state: State, target_state_name: String, payload: Dictionary = {}) -> void:
	if source_state != current_state:
		print("Invalid _handle_transition_to call - trying from %s, but currently in %s" % [source_state.name, target_state_name])
		return
	
	var new_state = states.get(target_state_name.to_lower())
	
	if not new_state:
		print("New state is empty")
		return
	
	payload.merge({ "source_state_name": source_state.name })
	
	current_state.exit()
	new_state.enter(payload)
	print("NEW STATE: ", new_state.name)
	
	current_state = new_state
