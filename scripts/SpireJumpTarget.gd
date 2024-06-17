@tool

class_name SpireJumpTarget
extends Area3D

@export_range(1.0, 100.0) var max_jump_distance = 16.0:
	set(value):
		max_jump_distance = value
		collision_shape.shape.radius = max_jump_distance

@export_range(1.0, 100.0) var max_jump_height = 4.0:
	set(value):
		max_jump_height = value
		collision_shape.shape.height = 2.0 * max_jump_height

@onready var collision_shape : CollisionShape3D = $CollisionShape3D

