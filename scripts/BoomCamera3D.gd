extends Node3D

signal set_camera_rotation(rotation: float)

@export var subject : Node3D
@export var first_person_anchor : Node3D
@export var third_person_anchor : Node3D
@export var default_anchor : Node3D
@export var camera_offset : Vector3 = Vector3.ZERO
@export_range(-90.0, 90.0) var default_pitch : float = 0.0

@onready var current_anchor := default_anchor
var platform_snap_target : Vector3 = Vector3.ZERO
var is_platform_snap_enabled : bool = false


@onready var yaw_pivot : Node3D = $YawPivot
@onready var pitch_pivot : Node3D = $YawPivot/PitchPivot
@onready var spring_arm : SpringArm3D = $YawPivot/PitchPivot/SpringArm3D
@onready var camera : Camera3D = $YawPivot/PitchPivot/SpringArm3D/Camera3D
@export var vertical_lerp_speed : float

@export var lerp_target_node: Node3D
@export var lerp_threshold: float = 5
var is_lerping : bool = true
var is_platform_snap_locked : bool = false

var subject_position : Vector3

#@onready var lerp_target : Vector3 = lerp_target_node.global_position

var forward : Vector3:
	get:
		return camera.get_global_transform().basis.z

var yaw : float = 0.0
var pitch : float = 0.0
var yaw_sensitivity : float = 0.07
var pitch_sensitivity : float = 0.07

@onready var position_offset : Vector3 = camera_offset
@onready var position_offset_target : Vector3 = camera_offset


const MAX_PITCH_ANGLE = deg_to_rad(30)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spring_arm.add_excluded_object(subject.get_rid())
	pitch = default_pitch
	pitch_pivot.rotation_degrees.x = default_pitch
	
	top_level = true
	
	camera.position = camera_offset


func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * yaw_sensitivity
		pitch += event.relative.y * pitch_sensitivity

func _physics_process(delta):
	position_offset = lerp(position_offset, position_offset_target, 25 * delta)
	
	var previous_subject_position = subject_position
	subject_position = subject.global_position
	
	if is_platform_snap_locked:
		subject_position.y = previous_subject_position.y
	
	var target = subject_position + position_offset
	
	global_position.x = lerp(global_position.x, target.x, 50 * delta)
	global_position.z = lerp(global_position.z, target.z, 50 * delta)
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

func enable_lerp():
	is_lerping = true

func disable_lerp():
	is_lerping = false

func get_forward_vector():
	return camera.get_global_transform().basis.z

func get_yaw_rotation():
	return yaw_pivot.rotation.y

func get_pitch_rotation():
	return pitch_pivot.rotation.x

func set_platform_snap_target(target: Vector3):
	platform_snap_target = target

func lock_platform_snap():
	is_platform_snap_locked = true

func release_platform_snap_target():
	platform_snap_target = Vector3.ZERO

func release_platform_snap():
	is_platform_snap_locked = false

#func lerp_to_target():
	#print("LERP ENABLED: ", is_lerping, ", LERP TARGET: ", lerp_target)
	#var diff = lerp_target - self.global_position
	#if abs(diff.y) >= lerp_threshold:
		#enable_lerp()
		#
	#if not is_lerping:
		#return
	#
	##lerp_target = lerp_target_node.global_position
	#self.position.y = lerp(self.position.y, diff.y, 0.25)
