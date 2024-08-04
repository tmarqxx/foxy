@tool
extends Path3D
class_name TightRopePath3D

@export_category("Progress Parameters")
@export_range(0.0, 1.0) var minimum_progress: float = 0.0
@export_range(0.0, 1.0) var maximum_progress: float = 1.0

@export_category("Polygon Parameters")
@export var number_of_vertices : int = 3:
	set(value):
		number_of_vertices = value
		_update_polygon(number_of_vertices, radius)
@export var radius : float = 1.0:
	set(value):
		radius = value
		_update_polygon(number_of_vertices, radius)

@onready var path_follow: PathFollow3D = $PathFollow3D
@onready var target_node: Node3D = $TargetNode3D
@onready var polygon: CSGPolygon3D = $CSGPolygon3D

var points = []

func _update_polygon(n: int, radius: float) -> void:
	points = []
	
	for i in range(n):
		var theta = PI * 2 / n * i
		var point = Vector2.ZERO
		point.x = radius * cos(theta)
		point.y = radius * sin(theta)
		points.append(point)
	

func _ready() -> void:
	#polygon.position = -position
	polygon.set_polygon(points)



func _update(delta: float) -> void:
	polygon.position = -position
#func _get_configuration_warnings():
	#var warnings = []
	#
	#if polygon == null:
		#warnings.append("TightRopePath3D requires a CSGPolygon3D node as a direct child")
		#
	#if path_follow == null:
		#warnings.append("TightRopePath3D requires a PathFollow3D node as a direct child")
		#
	#if remote_transform == null:
		#warnings.append("TightRopePath3D requires a RemoteTransform3D node as a child of the PathFollow3D node")
	#
	#return warnings

func get_tightrope_direction() -> Vector3:
	var start = curve.get_point_position(0)
	var end = curve.get_point_position(curve.point_count - 1)
	
	return start.direction_to(end)

#func set_remote_transform_path(path: NodePath) -> void:
	#remote_transform.set_remote_node(path)

func set_path_progress_from_position(position: Vector3) -> void:
	var offset = curve.get_closest_offset(position - global_position)
	var length = curve.get_baked_length()
	
	path_follow.set_progress(clamp(offset, minimum_progress * length, maximum_progress * length))

func update_path_progress(value: float) -> void:
	var length = curve.get_baked_length()
	path_follow.set_progress(clamp(path_follow.progress + value, minimum_progress * length, maximum_progress * length))

func get_up_vector() -> Vector3:
	return curve.sample_baked_up_vector(path_follow.progress)

func get_target_position() -> Vector3:
	return target_node.global_position

func reset():
	path_follow.set_progress(0.0)
	
	#remote_transform.set_remote_node(NodePath(""))
