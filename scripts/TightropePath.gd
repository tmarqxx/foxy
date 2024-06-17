@tool

class_name TightropePath
extends Path3D

@export var node_a : Node3D
@export var node_b : Node3D

@onready var path_follow : PathFollow3D = $PathFollow3D
@onready var remote_transform : RemoteTransform3D = $PathFollow3D/RemoteTransform3D

const MAX_POINT_COUNT = 2

func _ready():
	initialize_curve_points()

func initialize_curve_points():
	path_follow.set_v_offset(1.0)
	curve = Curve3D.new()
	var points: Array[Vector3] = []
	
	if node_a == null or node_b == null:
		return
	
	points.append(node_a.global_position)
	points.append(node_b.global_position)
	
	var start_position = points[0]
	var end_position = points[1]
	
	var middle_position = start_position.lerp(end_position, 0.5)
	var distance = start_position.distance_to(end_position)
	
	middle_position.y -= distance / 100
	
	var start_to_middle = start_position.direction_to(middle_position)
	var middle_to_end = middle_position.direction_to(end_position)
	
	curve.add_point(start_position, Vector3.ZERO, Vector3.DOWN + start_to_middle * distance / 4)
	curve.add_point(end_position, Vector3.DOWN - middle_to_end * distance / 4, Vector3.ZERO)

func get_tightrope_direction() -> Vector3:
	var start = curve.get_point_position(0)
	var end = curve.get_point_position(1)
	
	return start.direction_to(end)

func set_remote_transform_path(path: NodePath) -> void:
	remote_transform.set_remote_node(path)

func set_path_progress_from_position(position: Vector3) -> void:
	var start = curve.get_point_position(0)
	
	var offset = curve.get_closest_offset(position)
	path_follow.set_progress(clamp(offset, 1.0, curve.get_baked_length() - 1.0))


func update_path_progress(value: float) -> void:
	path_follow.set_progress(clamp(path_follow.progress + value, 1.0, curve.get_baked_length() - 1.0))

func get_up_vector() -> Vector3:
	return curve.sample_baked_up_vector(path_follow.progress)

func reset():
	path_follow.progress = 0.0
	
	remote_transform.set_remote_node(NodePath(""))
