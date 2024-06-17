extends RigidBody3D

@onready var anchor_point : Node3D = $AnchorPoint
@onready var raycast : RayCast3D = $RayCast3D

@onready var TightropePath = preload("res://scenes/TightropePath.tscn")
@onready var TightropeAnchor = preload("res://scenes/TightropeAnchor.tscn")

var initial_position : Vector3 = Vector3.ZERO
var initial_anchor_position : Vector3

func _disable():
	set_freeze_enabled(true)
	raycast.queue_free()
	

func _on_body_entered(body):
	print("HIT!")
	# check for valid collision 
	
	var collision_normal = raycast.get_collision_normal()
	self.global_transform.basis.z = collision_normal
	
	_disable()
	
	var tightrope = TightropePath.instantiate()
	get_tree().get_root().add_child(tightrope)
	
	self.reparent(tightrope)
	
	#var anchor_a = TightropeAnchor.instantiate()
	var other_tightrope_arrow = (load(scene_file_path) as PackedScene).instantiate()
	print("OTHER TIGHTROPE ANCHOR POINT: ", other_tightrope_arrow.get_node("AnchorPoint"))
	print("INITIAL_ANCHOR_POSITION  ", initial_anchor_position)
	other_tightrope_arrow.global_transform.origin = initial_anchor_position
	other_tightrope_arrow.rotation_degrees.x = -90
	print("other_tightrope_arrow.global_position ", other_tightrope_arrow.global_position)
	
	tightrope.add_child(other_tightrope_arrow)
	
	tightrope.node_a = self.anchor_point
	tightrope.node_b = other_tightrope_arrow.get_node("AnchorPoint")
	
	tightrope.initialize_curve_points()
	
