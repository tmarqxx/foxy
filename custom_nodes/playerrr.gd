extends DynamicCharacterBody3D
class_name Playerrr

#@export_category("Jump Attributes")
#@export var basic_jump: JumpData

@export_range(0.0, 100.0) var maximum_falling_speed: float = 50.0

@export var mouse_sensitivity: float = 0.05

@export var min_pitch: float = -89.9
@export var max_pitch: float = 50

@export var min_yaw: float = 0
@export var max_yaw: float = 360

@onready var active_camera: Camera3D = owner.get_node("%MainCamera3D")
@onready var follow_camera: PhantomCamera3D = %PlayerPhantomCamera3D
@onready var aim_camera: PhantomCamera3D
@onready var skin: Node3D = %PlayerSkin
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

@onready var camera_follow_target: Node3D = %CameraFollowTarget
@onready var camera_center_target: Node3D = %CameraCenterTarget
@onready var camera_forward_target: Node3D = %CameraForwardTarget

@onready var floor_raycast: RayCast3D = %FloorRayCast3D

var _previous_skin_transform: Transform3D
var _current_skin_transform: Transform3D

var gravity: float = 9.8
var is_gravity_enabled: bool = false
var is_movement_enabled: bool = true

#var direction: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	#active_camera = owner.get_node("%MainCamera3D")
	#follow_camera = owner.get_node("%PlayerPhantomCamera3D")
	#skin.top_level = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#follow_camera.follow_offset.y = camera_follow_target.position.y

func _unhandled_input(event):
	_set_pcam_rotation(follow_camera, event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
	#skin.global_position = _previous_skin_transform.interpolate_with(
		#_current_skin_transform,
		#Engine.get_physics_interpolation_fraction()
	#).origin
	
	#skin.global_basis = _previous_skin_transform.interpolate_with(
		#
	#).basis
	
	#if velocity.length() > 0.01:
	#var look_direction = velocity
	#look_direction.y = 0
	#skin.look_at(skin.global_position + look_direction, Vector3.UP)

func ease_in_out_quad(start: float, end: float, delta: float) -> float:
	delta /= 0.5
	end -= start
	
	if delta < 1:
		return end * 0.5 * delta * delta + start
		
	delta -= 1
	return -end * 0.5 * (delta * (delta - 2) - 1) + start

func ease_in_out(start: Vector3, end: Vector3, delta: float) -> Vector3:
	delta /= 0.5
	end -= start
	
	if delta < 1:
		return end * 0.5 * delta * delta + start
		
	delta -= 1
	return -end * 0.5 * (delta * (delta - 2) - 1) + start

func _physics_process(delta):
	#_previous_skin_transform.origin = _current_skin_transform.origin
	#_current_skin_transform.origin = global_transform.origin
	
	#print("VEL: ", velocity.length())
	#if velocity.length() > 1.0:
		#follow_camera.follow_damping_value = Vector3(0.05, 10, 0.05)
		#camera_follow_target.global_position = camera_follow_target.global_position.lerp(camera_center_target.global_position, 2 * delta)
		#follow_camera.follow_offset.y =
		#follow_camera.follow_offset.x = lerp(follow_camera.follow_offset.x, 0.0, 4 * delta)
		#follow_camera.follow_offset.z = lerp(follow_camera.follow_offset.z, 0.0, 4 * delta)
		#camera_follow_offset_target.global_position += skin.global_basis.z * 5 * delta
	#else:
		#follow_camera.follow_damping_value = Vector3(0.5, 10, 0.5)
	camera_follow_target.global_position = ease_in_out(camera_follow_target.global_position, camera_forward_target.global_position, 8 * delta)
		#var offset = camera_follow_target.global_position - global_position
		#follow_camera.follow_offset.x = lerp(follow_camera.follow_offset.x, offset.x, 4 * delta)
		#follow_camera.follow_offset.z = lerp(follow_camera.follow_offset.z, offset.z, 4 * delta)
		#follow_camera.follow_offset = follow_camera.follow_offset.lerp(, 4 * delta)
	
	#print("PLAYER POS: ", global_position, ", CAM OFFSET POS: ", camera_follow_offset_target.global_position)
	
	#if is_moving():
		#follow_camera.follow_damping_value = Vector3(0.1, 10, 0.1)
		#follow_camera.follow_offset = Vector3.ZERO
	#else:
		#var follow_offset = camera_follow_offset_target.global_position - global_position
		#follow_camera.follow_damping_value.x += 4 * delta
		#follow_camera.follow_damping_value.z += 4 * delta = Vector3(0.5, 10, 0.5)
		#
		#follow_camera.follow_damping_value.x = clamp()
		#follow_camera.follow_offset = follow_offset

	#_previous_skin_transform.basis = _current_skin_transform.basis
	#_current_skin_transform.basis = global_transform.basis
	
	#if is_gravity_enabled and not is_on_floor():
		#velocity.y += gravity * delta
	
	if not is_movement_enabled:
		return
	
	velocity.y = clamp(velocity.y, -maximum_falling_speed, 2 * maximum_falling_speed)
	
	#orient_forward(delta)
	move_and_slide()

#func apply_acceleration(direction: Vector3, acceleration: float, max_speed: float, delta: float) -> void:
	#if direction.length() > deadzone:
		#accelerate_toward(direction, acceleration, delta)
	#else:
		#accelerate_toward(velocity.normalized(), -acceleration, delta)
	#
	#limit_velocity_length(max_speed)

#func accelerate_toward(direction: Vector3, maginitude: float, delta: float) -> void:
	#direction = direction.normalized()
	#var target_velocity = velocity + (direction * maginitude * delta)
#
	#velocity += target_velocity
#
#func limit_velocity_length(limit: float) -> void:
	#if limit < 0.0:
		#push_warning("DynrmaicCharacterBody3D.limit_velocity_length - limit parameter only uses values above 0.0")
	#
	#limit = abs(limit)
#
	#velocity = velocity.normalized() * limit

func _set_pcam_rotation(pcam: PhantomCamera3D, event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pcam_rotation_degrees: Vector3

		# Assigns the current 3D rotation of the SpringArm3D node - so it starts off where it is in the editor
		pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()

		# Change the X rotation
		pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity

		# Clamp the rotation in the X axis so it go over or under the target
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)

		# Change the Y rotation value
		pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity

		# Sets the rotation to fully loop around its target, but witout going below or exceeding 0 and 360 degrees respectively
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_yaw, max_yaw)

		# Change the SpringArm3D node's rotation and rotate around its target
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)

func look_forward() -> void:
	var movement_direction := get_movement_direction()
	var look_direction :=  Vector2(-movement_direction.z, -movement_direction.x).normalized()
	if look_direction.length() > 0.01:
		skin.rotation.y = look_direction.angle()
	#skin.look_at(skin.global_position + velocity, Vector3.UP)

func look_toward(direction: Vector3, delta: float):
	var look_direction :=  Vector2(-direction.z, -direction.x).normalized()
	
	if look_direction.length() > 0.01:
		var target_angle = look_direction.angle()
		#if abs(skin.rotation.y - target_angle) < abs(target_angle):
			#target_angle = skin.rotation.y - target_angle
		#var target_angle = global_position.angle_to(direction)

		skin.rotation.y = lerp_angle(skin.rotation.y, target_angle, delta)
		#skin.global_rotation.y = lerp_angle(skin.global_rotation.y, atan2(-direction.x, -direction.z), 20 * delta)

func orient_forward(delta: float) -> void:
	#var target = global_position + velocity
	#target.y = 0
	#look_at(target, Vector3.UP)
	var direction = velocity
	direction.y = 0
	direction = direction.normalized()
	
	if direction.length() > 0.01:
		skin.global_rotation.y = lerp_angle(skin.global_rotation.y, atan2(-direction.x, -direction.z), 20 * delta)

#func get_gravity() -> float:
	#if velocity.y > 0.0:
		#return basic_jump.gravity
	#
	#return basic_jump.fall_gravity

func is_on_trampoline() -> bool:
	var collision = get_last_slide_collision()
	
	if collision == null:
		return false
	
	return is_on_floor() and collision.get_collider() is BounceArea3D

func get_trampoline_collider():
	var collider = get_last_slide_collision().get_collider()
	
	if not collider is BounceArea3D:
		return null
	
	return collider

func is_moving() -> bool:
	return get_input_direction().length() > input_deadzone

func get_input_direction() -> Vector3:
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	var direction = Vector3.ZERO
	direction.x = input_dir.x
	direction.z = input_dir.y
	
	return direction.normalized()

func get_lateral_velocity() -> Vector3:
	return Vector3(velocity.x, 0, velocity.z)

func get_movement_direction() -> Vector3:
	var input_direction = get_input_direction()
	var movement_direction = Vector3(input_direction.x, 0, input_direction.z)
		#var move_dir: Vector3 = Vector3.ZERO
		#move_dir.x = direction.x
		#move_dir.z = direction.z

	return movement_direction.rotated(Vector3.UP, active_camera.rotation.y).normalized()
	#var direction = get_input_direction()
	#var cam_forward = -active_camera.global_transform.basis.z
	#var cam_right = active_camera.global_transform.basis.x
	#
	#return cam_forward * -direction.z + cam_right * direction.x

func set_camera_damping(damping: Vector3) -> void:
	follow_camera.follow_damping_value = damping
