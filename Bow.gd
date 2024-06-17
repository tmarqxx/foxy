extends Node3D
class_name Bow

@export var player : Player
@export var stats : ArrowStats

var current_arrow : Node

var draw_length : float = 1.0
var time_to_draw : float = 0.25
var draw_time : float = 0.0

@onready var mesh : MeshInstance3D = $MeshInstance3D
@onready var string_path : Path3D = $Path3D
@onready var timer : Timer = $Timer
@onready var string_anchor_top : Node3D = $StringAnchorTop
@onready var string_nock_point : Node3D = $StringNockPoint
@onready var string_anchor_bottom : Node3D = $StringAnchorBottom
@onready var raycast : RayCast3D = $RayCast3D

@onready var TightropeArrow = preload("res://scenes/TightropeArrow.tscn")

var shoot_direction : Vector3 = Vector3.ZERO

func _ready():
	string_path.curve.add_point(string_anchor_top.global_position)
	string_path.curve.add_point(string_nock_point.global_position)
	string_path.curve.add_point(string_anchor_bottom.global_position)

func get_shoot_direction() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	var viewport_size = get_viewport().get_size()
	
	var ray_origin = camera.project_ray_origin(viewport_size / 2)
	var ray_end = ray_origin + camera.project_ray_normal(viewport_size / 2) * 600
	
	return (ray_end - self.global_position).normalized()

func draw(delta: float):
	var shoot_direction = get_shoot_direction()
	
	
	if draw_time > time_to_draw:
		print("ARROW READY!!")
		return
	
	draw_time += delta
	string_nock_point.position.z = lerp(string_nock_point.position.z, string_nock_point.position.z + (draw_time / time_to_draw) * draw_length, 5 * delta)

func shoot():
	if not raycast.is_colliding():
		return
	
	if draw_time > time_to_draw:
		# fire arrow
		var direction = get_shoot_direction()
		var new_arrow : RigidBody3D = TightropeArrow.instantiate()
		new_arrow.set_freeze_enabled(false)

		add_child(new_arrow)
		print("RAYCAST? ", raycast.is_colliding())
		if raycast.is_colliding():
			print("RAYCAST POINT ", raycast.get_collision_point())
			new_arrow.initial_anchor_position = raycast.get_collision_point()
		
		#new_arrow.initial_position = player.global_position + player.camera.global_transform.basis.x
		#var basis = new_arrow.global_transform.looking_at(direction)
		#new_arrow.set_global_transform(basis)
		new_arrow.apply_impulse(direction * 200)
	
	cancel()

func cancel():
	draw_time = 0.0
	string_nock_point.position.z = 0.0
	shoot_direction = Vector3.ZERO

func _process(delta):
	if not draw_time > 0.0:
		return
	
	#mesh.look_at_from_position(global_position, -shoot_direction)
	
	string_path.curve.set_point_position(0, string_anchor_top.global_position)
	string_path.curve.set_point_position(1, string_nock_point.global_position)
	string_path.curve.set_point_position(2, string_anchor_bottom.global_position)


func _on_body_entered(body):
	pass # Replace with function body.
