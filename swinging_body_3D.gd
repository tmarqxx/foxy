extends RigidBody3D
class_name SwingingBody3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var _reset_requested: bool = false

var _impulse_to_apply: Vector3 = Vector3.ZERO
var _apply_impulse_requested: bool = false

func _ready() -> void:
	custom_integrator = true
	reset()

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if _reset_requested:
		_reset_requested = false
		
		set_freeze_enabled(true)
		set_as_top_level(false)
		collision_shape.set_disabled(true)
		
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		state.transform = Transform3D.IDENTITY
	elif _apply_impulse_requested:
		_apply_impulse_requested = false
		
		set_freeze_enabled(false)
		set_as_top_level(true)
		collision_shape.set_disabled(false)
		
		state.apply_central_impulse(_impulse_to_apply)
	
	if not is_freeze_enabled():
		var gravity_vector = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")
		state.add_constant_central_force(gravity_vector * state.get_step())

func start(impulse: Vector3) -> void:
	_impulse_to_apply = impulse
	_apply_impulse_requested = true

func reset() -> void:
	_reset_requested = true
