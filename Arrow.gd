class_name Arrow
extends RigidBody3D

@export_range(0, 5.0) var time_to_draw : float = 1.0
@export_range(0.0, 100.0) var initial_force : float = 0.0

func shoot(target: Vector3) -> void:
	self.apply_central_impulse(target * initial_force)
