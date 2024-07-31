extends CharacterBody3D
class_name NewPlayer

@export_category("Acceleration")
@export_range(0.1, 5.0) var ground_acceleration_time: float = 0.1
@export_range(0.1, 5.0) var ground_deceleration_time: float = 0.1
@export_range(0.1, 5.0) var air_acceleration_time: float = 0.1
@export_range(0.1, 5.0) var air_deceleration_time: float = 0.1

@export_category("Max Speed")
@export var max_ground_speed: float = 7.0
@export var max_air_speed: float = 9.0
@export var crawl_speed: float = 6.0

@onready var ground_acceleration: float = max_ground_speed / ground_acceleration_time
@onready var ground_deceleration: float = -max_ground_speed / ground_deceleration_time
@onready var air_acceleration: float = max_air_speed / air_acceleration_time
@onready var air_deceleration: float = -max_air_speed / air_deceleration_time

@export_category("Jump Attributes")
@export var basic_jump: Resource

@onready var mesh_rig: Node3D = $StandingCollision/MeshRig
@onready var camera: PlayerCamera3D = $PlayerCamera3D

var current_speed: float = 0.0
var max_speed: float = max_ground_speed
#var direction: Vector3 = Vector3.ZERO
var acceleration: float = 0.0

var _is_jump_buffered: bool = false


func move(delta: float, direction: Vector3 = get_movement_direction()) -> void:
	#velocity.y += get_gravity() * delta
	print("DIR: ", direction)
	print("ACC: ", acceleration)
	print("VEL: ", velocity)
	print("MAX SPEED: ", max_speed)
	
	#velocity.x += acceleration.x * delta
	#velocity.z += acceleration.z * delta
	
	current_speed += acceleration * delta
	current_speed = clamp(current_speed, 0.0, max_speed)
	
	
	if acceleration > 0.01:
		#velocity.x = min(velocity.x + (direction.x * acceleration * delta), max_speed)
		#velocity.z = min(velocity.z + (direction.z * acceleration * delta), max_speed)
		#velocity.x = clamp(velocity.x, -max_speed, max_speed)
		#velocity.z = clamp(velocity.z, -max_speed, max_speed)
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		orient_forward()
	else:
		velocity.x = velocity.normalized().x * current_speed
		velocity.z = velocity.normalized().z * current_speed
	#else:
		#velocity.x = clamp(velocity.x, 0.0, max_speed)
		#velocity.z = clamp(velocity.z, 0.0, max_speed)
	#else:
		#velocity.x = max(velocity.x + (direction.x * acceleration * delta), 0.0)
		#velocity.z = max(velocity.z + (direction.z * acceleration * delta), 0.0)
	
	
	
	move_and_slide()

func orient_forward() -> void:
	#var target = global_position + velocity
	#target.y = 0
	#look_at(target, Vector3.UP)
	mesh_rig.global_rotation.y = lerp_angle(mesh_rig.global_rotation.y, atan2(-velocity.x, -velocity.z), 0.5)

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
