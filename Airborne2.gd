extends State

var current_payload: Dictionary

var player : NewPlayer

var time_of_jump: float
var jump_direction: Vector3 = Vector3.ZERO

var is_double_jump_available: bool = true
var is_double_jump_buffered: bool = false

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
	player.max_speed = player.max_air_speed
	player.current_speed = 0.0
	player.acceleration = 0.0
	
	if payload.has("ground_jump"):
		is_double_jump_available = true
		time_of_jump = Time.get_unix_time_from_system()
		player.velocity.y = player.basic_jump.velocity
	elif payload.has("air_jump"):
		is_double_jump_available = false
		player.velocity.y += player.basic_jump.velocity / 2

func exit():
	jump_direction = Vector3.ZERO
	pass

func handle_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		is_double_jump_buffered = true

func update(delta):
	pass

func physics_update(delta):
	var direction = player.get_movement_direction()
	var current_time = Time.get_unix_time_from_system()
	
	player.velocity.y += player.get_gravity() * delta
	
	if player.is_on_floor():
		transition_to.emit(self, "Grounded")
	
	if is_double_jump_buffered and current_time > time_of_jump + player.basic_jump.time_to_peak and is_double_jump_available:
		enter({ "air_jump": true })
		return
	
	if current_time < time_of_jump + (player.basic_jump.time_to_peak / 4):
		if not jump_direction.length() > 0.0:
			jump_direction = direction
		
		player.current_speed = player.max_air_speed
		player.acceleration = player.air_acceleration
		
		player.move(delta, jump_direction)
		
		return
	elif direction.length() > 0.01:
		player.acceleration = player.air_acceleration
	else:
		player.acceleration = player.air_deceleration
		#player.velocity += jump_direction * player.air_deceleration * delta
	
	player.move(delta)
	#player.move(delta, direction)

