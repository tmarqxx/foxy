class_name Player
extends CharacterBody3D

signal pressed_jump()
#signal changed_stance(stance : Stance)
#signal changed_movement_state(_movement_state: MovementState)
signal update_movement_direction(direction: Vector3)

@export var state_machine : StateMachine
@export var animation_tree : AnimationTree
@export var mesh_root: Node3D
@export var skin : Node3D
@export var camera : PlayerCamera3D

@export_category("Speed Attributes")
@export var movement_speed : float
@export_range (0.0, 1.0) var airborne_speed : float = 1.0
@export_range (1.0, 10.0) var sprint_speed : float = 1.5
@export var maximum_falling_speed : float = 30

@export_category("Jump Attributes")
@export var jump_peak_height : float
@export var jump_time_to_peak: float
@export var jump_hang_time: float
@export var jump_time_to_descend: float
#@export var jump_peak_distance : float
@export var jump_distance_to_peak : float
@export var jump_distance_to_floor: float

@onready var jump_velocity := (2.0 * jump_peak_height) / jump_time_to_peak
@onready var jump_gravity := (-2.0 * jump_peak_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity := (-2.0 * jump_peak_height) / (jump_time_to_descend * jump_time_to_descend)

@export_category("Dive Attributes")
@export var dive_peak_height: float
@export var dive_time_to_peak: float
@export var dive_time_to_descened: float

#@onready var dive_velocity := (2.0 * dive_peak_height) / dive_time_to_peak
#@onready var dive_gravity := (-2.0 * jump_peak_height) / (jump_time_to_peak * jump_time_to_peak)
#@onready var _gravity := (-2.0 * jump_peak_height) / (jump_time_to_descend * jump_time_to_descend)


@onready var standing_collision : CollisionShape3D = $StandingCollision
@onready var edge_raycast_head: RayCast3D = $GobotSkin/EdgeRayCast
@onready var edge_raycast_body: RayCast3D = $GobotSkin/EdgeRayCast2
@onready var bounce_raycast: RayCast3D = $GobotSkin/BounceRaycast

#@onready var jump_velocity : float = (2.0 * jump_peak_height * 10.0) / jump_distance_to_peak
#@onready var jump_gravity : float = (-2.0 * jump_peak_height * pow(10.0, 2)) / pow(jump_distance_to_peak, 2)
#@onready var fall_gravity : float = (-2.0 * jump_peak_height * pow(10.0, 2)) / pow(jump_distance_to_floor, 2)
@onready var initial_rotation : float = self.rotation.y

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity = 0.001

var current_speed : float
var current_direction : Vector3
var previous_direction : Vector3

var spawn_position : Vector3

func _ready():
	spawn_position = self.global_position
	#DebugOverlay.draw.add_vector(self, "velocity", 1, 1, Color(0, 0, 1, 0.5))

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if event.is_action_pressed("movement") or event.is_action_released("movement"):
		_update_current_direction()
		
		#if is_sprinting():
			#state_machine.transition_to("sprinting")
		#elif is_moving():
			#state_machine.transition_to("walking")
		#else:
			#state_machine.transition_to("idle")
	
	#if event.is_action_pressed("jump") and is_on_floor():
		#state_machine.transition_to("airborne", { "ground_jump": true })
	#elif event.is_action_pressed("jump"):
		#state_machine.transition_to("airborne", { "air_jump": true })
	

func _physics_process(delta: float):
	if self.global_position.y < -20.0:
		self.global_position = spawn_position
	#var direction = current_direction.rotated(Vector3.UP, camera.get_yaw_rotation()) * -1
	#
	#if not is_on_floor():
		#velocity.y += get_gravity() * delta
		#velocity.y = clamp(velocity.y, -maximum_falling_speed, 10000)
	#
	#if is_moving():
		#velocity.x = direction.x * current_speed
		#velocity.z = direction.z * current_speed
		#
		#mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, atan2(direction.x, direction.z), 20 * delta)
	#else:
		#velocity.x = move_toward(velocity.x, 0, current_speed)
		#velocity.z = move_toward(velocity.z, 0, current_speed)
	#
	#move_and_slide()

func is_moving() -> bool:
	return _get_input_direction().length() > 0.0

func is_sprinting() -> bool:
	return is_moving() and Input.is_action_pressed("sprint")

func get_gravity() -> float:
	if velocity.y > 0.0:
		return jump_gravity
	
	return fall_gravity

func _get_input_direction() -> Vector3:
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	var direction = Vector3.ZERO
	direction.x = input_dir.x
	direction.z = input_dir.y
	
	return direction

func _update_current_direction():
	if current_direction.length() > 0:
		previous_direction = current_direction
	
	current_direction = _get_input_direction()

func get_camera_forward() -> Vector3:
	return camera.get_forward_vector()

func get_movement_direction() -> Vector3:
	var cam_forward = camera.get_forward_vector()
	var cam_right = camera.get_right_vector()
	
	return cam_forward * -current_direction.z + cam_right * current_direction.x

func orient_toward(delta: float, direction: Vector3) -> void:
	skin.global_rotation.y = lerp_angle(skin.global_rotation.y, atan2(-direction.x, -direction.z), 20 * delta)

func move(delta: float, speed: float, direction: Vector3 = get_movement_direction()) -> void:
	#var direction = get_movement_direction()
	
	if direction.length() > 0.0:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		orient_toward(delta, direction)
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		velocity.z = move_toward(velocity.z, 0, movement_speed)
	
	move_and_slide()

func set_up_vector(up: Vector3 = Vector3.UP) -> void:
	var basis = skin.global_basis
	basis.y = up
	#if up == Vector3.ZERO:
		#basis.z = -1 * get_movement_direction()
	#else:
	basis.x = -basis.z.cross(up)
	basis = basis.orthonormalized()
	skin.global_basis = basis

func reset_mesh_basis():
	skin.global_basis = Basis.IDENTITY

func disable_collision():
	standing_collision.set_disabled(true)

func enable_collision():
	standing_collision.set_disabled(false)

func is_on_edge():
	return edge_raycast_body.is_colliding() and not edge_raycast_head.is_colliding()

func is_on_wall_surface():
	return edge_raycast_body.is_colliding() and edge_raycast_head.is_colliding()

func is_on_trampoline():
	return bounce_raycast.is_colliding()

func get_trampoline_collider():
	return bounce_raycast.get_collider()

func handle_bounce():
	pass

func _on_climb_buffer_timer_timeout():
	pass # Replace with function body.
