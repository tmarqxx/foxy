@tool
extends StaticBody3D

@export var mesh_node : MeshInstance3D
@export var collision_node : CollisionShape3D

@export var size := Vector3(5, 0.5, 5):
	set = _set_platform_size

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_platform_size(size)

func _set_platform_size(value: Vector3):
	size = value
	mesh_node.mesh.size = size
	collision_node.shape.size = size
