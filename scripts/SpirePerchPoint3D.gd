@tool
extends Area3D

@onready var floor_collision_shape: CollisionShape3D = $StaticBody3D/FloorCollisionShape3D

var disabled: bool = true:
	set(value):
		disabled = value
		floor_collision_shape.set_disabled(disabled)

func _ready() -> void:
	floor_collision_shape.set_disabled(true)
