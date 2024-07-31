@tool
extends Path3D
class_name DepTightRopePath3D

@export_category("Progress Parameters")
@export_range(0.0, 1.0) var minimum_progress: float = 0.0
@export_range(0.0, 1.0) var maximum_progress: float = 1.0

var polygon: CSGPolygon3D:
	set(value):
		polygon = value
		update_configuration_warnings()
var path_follow: PathFollow3D:
	set(value):
		path_follow = value
		update_configuration_warnings()
var remote_transform: RemoteTransform3D:
	set(value):
		remote_transform = value
		update_configuration_warnings()

# Called when the node enters the scene tree for the first time.
func _ready():
	#polygon = NodeUtilities.get_child_of_type(self, DynamicCSGPolygon3D)
	polygon.position = -position
	
	path_follow = NodeUtilities.get_child_of_type(self, PathFollow3D)
	remote_transform = NodeUtilities.get_child_of_type(path_follow, RemoteTransform3D)

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
	var end = curve.get_point_position(1)
	
	return start.direction_to(end)

func set_remote_transform_path(path: NodePath) -> void:
	remote_transform.set_remote_node(path)

func set_path_progress_from_position(position: Vector3) -> void:
	var start = curve.get_point_position(0)
	
	var offset = curve.get_closest_offset(position)
	var length = curve.get_baked_length()
	
	path_follow.set_progress(clamp(offset, minimum_progress * length, maximum_progress * length))

func update_path_progress(value: float) -> void:
	var length = curve.get_baked_length()
	path_follow.set_progress(clamp(path_follow.progress + value, minimum_progress * length, maximum_progress * length))

func get_up_vector() -> Vector3:
	return curve.sample_baked_up_vector(path_follow.progress)

func get_target_position() -> Vector3:
	return remote_transform.global_position

func reset():
	path_follow.progress = 0.0
	
	remote_transform.set_remote_node(NodePath(""))

