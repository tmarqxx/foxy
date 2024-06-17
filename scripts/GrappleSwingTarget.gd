@tool

class_name GrappleSwingTarget
extends Area3D

@export_range(1.0, 100.0) var max_grapple_distance = 16.0:
	set(value):
		max_grapple_distance = value
		collision_shape.shape.radius = max_grapple_distance

@onready var collision_shape : CollisionShape3D = $CollisionShape3D
@onready var static_body : StaticBody3D = $StaticBody3D

func get_static_body() -> StaticBody3D:
	return static_body
