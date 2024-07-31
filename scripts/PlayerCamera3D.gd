extends Node3D
class_name PlayerCamera3D
signal set_camera_rotation(rotation: float)


@export var subject : Node3D
@export var camera_offset : Vector3 = Vector3.ZERO
@export var fov : float = 75.0:
	set(value):
		fov = value
		camera.fov = fov
@export_range(-90.0, 90.0) var default_pitch : float = 0.0

@onready var yaw_pivot : Node3D = $YawPivot
@onready var pitch_pivot : Node3D = $YawPivot/PitchPivot
@onready var spring_arm : SpringArm3D = $YawPivot/PitchPivot/SpringArm3D
@onready var camera : Camera3D = $YawPivot/PitchPivot/SpringArm3D/Camera3D

@export var vertical_lerp_speed : float

@export var lerp_target_node: Node3D
@export var lerp_threshold: float = 5

const PLATFORM_SNAP_RELEASE_THRESHOLD : float = 6.0

var is_lerping : bool = true
var is_platform_snap_locked : bool = false

var subject_position : Vector3
var subject_offset : Vector3 = Vector3.ZERO

#@onready var lerp_target : Vector3 = lerp_target_node.global_position

var forward : Vector3:
	get:
		return camera.get_global_transform().basis.z

var yaw : float = 0.0
var pitch : float = 0.0
var yaw_sensitivity : float = 0.07
var pitch_sensitivity : float = 0.07

var sensitivity_scale : float = 1.0

@onready var position_offset : Vector3 = camera_offset
@onready var position_offset_target : Vector3 = camera_offset


const MAX_PITCH_ANGLE = deg_to_rad(30)

var platform_snap_position : Vector3 = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#spring_arm.add_excluded_object(subject.get_rid())
	pitch = default_pitch
	pitch_pivot.rotation_degrees.x = default_pitch
	
	top_level = true
	
	camera.global_position = camera_offset


func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * yaw_sensitivity * sensitivity_scale
		pitch -= event.relative.y * pitch_sensitivity * sensitivity_scale

func _physics_process(delta):
	position_offset = lerp(position_offset, position_offset_target, 1.0)
	
	var previous_subject_position = subject_position
	subject_position = subject.global_position
	
	if is_platform_snap_locked:
		var diff = subject_position.y - platform_snap_position.y
		
		if diff > PLATFORM_SNAP_RELEASE_THRESHOLD or diff < -1.0:
			release_platform_snap()
	
	if is_platform_snap_locked:
		subject_position.y = platform_snap_position.y
	
	
	var target = subject_position + position_offset + subject_offset
	
	global_position.x = lerp(global_position.x, target.x, 5 * delta)
	global_position.z = lerp(global_position.z, target.z, 5 * delta)
	global_position.y = lerp(global_position.y, target.y, 10 * delta)
	
	pitch = clamp(pitch, -40, 60)
	
	yaw_pivot.rotation_degrees.y = lerp(yaw_pivot.rotation_degrees.y, yaw, 50 * delta)
	pitch_pivot.rotation_degrees.x = lerp(pitch_pivot.rotation_degrees.x, pitch, 50 * delta)
	#pitch_pivot.rotate_x(pitch)
	#pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	
	#if you don't want to lerp, set them directly
	#yaw_node.rotation_degrees.y = yaw
	#pitch_node.rotation_degrees.x = pitch
	
	#set_camera_rotation.emit(yaw_pivot.rotation.y)
	#yaw = 0.0
	#pitch = 0.0

func handle_roll_input(angle: float):
	yaw_pivot.rotate_y(angle)

func handle_pitch_input(angle: float):
	pitch_pivot.rotate_x(angle)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, -MAX_PITCH_ANGLE, MAX_PITCH_ANGLE)

func get_forward_vector():
	return -camera.get_global_transform().basis.z

func get_right_vector():
	return camera.get_global_transform().basis.x

func get_yaw_rotation():
	return yaw_pivot.rotation.y

func get_pitch_rotation():
	return pitch_pivot.rotation.x

func lock_platform_snap():
	if is_platform_snap_locked:
		return
	
	relock_platform_snap()

func relock_platform_snap():
	is_platform_snap_locked = true
	platform_snap_position = subject.global_position

func release_platform_snap():
	is_platform_snap_locked = false
