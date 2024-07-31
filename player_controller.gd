extends DynamicCharacterBody3D

@export_category("Speed and Acceleration")
@export_range(0.1, 5.0) var TIME_TO_GROUND_SPEED: float = 0.1
@export_range(0.1, 5.0) var TIME_TO_GROUND_STOP: float = 0.1
@export_range(0.1, 5.0) var TIME_TO_AIR_SPEED: float = 0.1
@export_range(0.1, 5.0) var TIME_TO_AIR_STOP: float = 0.1

@export var MAX_GROUND_SPEED: float = 7.0
@export var MAX_AIR_SPEED: float = 7.0
@export var MAX_CRAWL_SPEED: float = 7.0

@onready var GROUND_ACCELERATION: float = MAX_GROUND_SPEED / TIME_TO_GROUND_SPEED
@onready var GROUND_DECELERATION: float = -MAX_GROUND_SPEED / TIME_TO_GROUND_STOP
@onready var AIR_ACCELERATION: float = MAX_AIR_SPEED / TIME_TO_AIR_SPEED
@onready var AIR_DECELERATION: float = -MAX_AIR_SPEED / TIME_TO_AIR_STOP

@export_category("Jump Attributes")
@export var basic_jump: Resource

@onready var player_visual: Node3D = %PlayerModel
@onready var camera: PlayerCamera3D = %MainCamera3D

var current_speed: float = 0.0
var max_speed: float = MAX_GROUND_SPEED
#var direction: Vector3 = Vector3.ZERO
var acceleration: float = 0.0

var _previous_body_transform: Transform3D
var _current_body_transform: Transform3D


func _ready() -> void:
	player_visual.top_level = true


# func _physics_process(delta) -> void:

# 	current_speed += acceleration * delta
# 	current_speed = clamp(current_speed, 0.0, max_speed)
	
	
# 	if acceleration > 0.01:
# 		#velocity.x = min(velocity.x + (direction.x * acceleration * delta), max_speed)
# 		#velocity.z = min(velocity.z + (direction.z * acceleration * delta), max_speed)
# 		#velocity.x = clamp(velocity.x, -max_speed, max_speed)
# 		#velocity.z = clamp(velocity.z, -max_speed, max_speed)
# 		velocity.x = direction.x * current_speed
# 		velocity.z = direction.z * current_speed
# 		orient_forward()
# 	else:
# 		velocity.x = velocity.normalized().x * current_speed
# 		velocity.z = velocity.normalized().z * current_speed
# 	#else:
# 		#velocity.x = clamp(velocity.x, 0.0, max_speed)
# 		#velocity.z = clamp(velocity.z, 0.0, max_speed)
# 	#else:
# 		#velocity.x = max(velocity.x + (direction.x * acceleration * delta), 0.0)
# 		#velocity.z = max(velocity.z + (direction.z * acceleration * delta), 0.0)
	
	
	
# 	move_and_slide()


func _process(delta) -> void:
	player_visual.global_transform = _previous_body_transform.interpolate_with(
		_current_body_transform,
		Engine.get_physics_interpolation_fraction()
	)

func get_gravity() -> float:
	if velocity.y > 0.0:
		return basic_jump.gravity

	return basic_jump.fall_gravity

func is_moving() -> bool:
	return get_input_direction().length() > 0.01

func get_input_direction() -> Vector3:
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	var direction = Vector3.ZERO
	direction.x = input_dir.x
	direction.z = input_dir.y
	
	return direction.normalized()

func get_movement_direction() -> Vector3:
	var direction = get_input_direction()
	var cam_forward = camera.get_forward_vector()
	var cam_right = camera.get_right_vector()
	
	return cam_forward * -direction.z + cam_right * direction.x
