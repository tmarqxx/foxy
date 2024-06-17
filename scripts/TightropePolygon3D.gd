extends "res://scripts/DynamicPolygon3D.gd"

func _ready():
	super._ready()
	
	assert(get_parent() is TightropePath)

func get_tightrope_direction() -> Vector3:
	var start = get_parent().curve.get_point_position(0)
	var end = get_parent().curve.get_point_position(1)
	
	return start.direction_to(end)

func get_tightrope_follow_node() -> PathFollow3D:
	return get_node("../PathFollow3D")
