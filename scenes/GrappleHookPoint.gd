@tool

class_name GrappleHookPoint
extends Area3D

@export_range(1.0, 100.0) var max_grapple_distance = 16.0

@onready var hook_point : Node3D = $HookPoint
@onready var collision_shape : CollisionShape3D = $CollisionShape3D

func _ready():
	collision_shape.shape.radius = max_grapple_distance

func get_hook_point() -> Node3D:
	return hook_point
