extends State

var current_payload: Dictionary

var player : NewPlayer

func _ready():
	# The states are children of the `Player` node so their `_ready()` callback will execute first.
	# That's why we wait for the `owner` to be ready first.
	await owner.ready
	# The `as` keyword casts the `owner` variable to the `Player` type.
	# If the `owner` is not a `Player`, we'll get `null`.
	player = owner as NewPlayer
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than `Player.tscn`, which would be unintended. This can
	# help prevent some bugs that are difficult to understand.
	assert(player != null)

func enter(payload: Dictionary = {}):
	current_payload = payload
	player.max_speed = player.max_ground_speed
	player.acceleration = player.ground_acceleration
	pass

func exit():
	pass

func handle_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		transition_to.emit(self, "Airborne", { "ground_jump": true })

func update(_delta):
	pass

func physics_update(delta):
	if not player.is_on_floor():
		transition_to.emit(self, "Airborne")
	
	var direction = player.get_movement_direction()
	print("MOVEMENT DIR: ", direction)
	
	if direction.length() > 0.01:
		#player.direction = direction
		player.acceleration = player.ground_acceleration
	else:
		player.acceleration = player.ground_deceleration
	
	player.move(delta)

