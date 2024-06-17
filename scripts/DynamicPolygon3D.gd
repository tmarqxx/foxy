@tool
extends CSGPolygon3D
class_name DynamicPolygon3D

@export var number_of_vertices : int = 0:
	set(value):
		number_of_vertices = value
		_update_polygon(number_of_vertices, radius)
@export var radius : float = 1.0:
	set(value):
		radius = value
		_update_polygon(number_of_vertices, radius)

var points: Array[Vector2] = []

func _ready():
	set_polygon(points)

func _update_polygon(n: int, radius: float) -> void:
	points = []
	
	for i in range(n):
		var theta = PI * 2 / n * i
		var point = Vector2.ZERO
		point.x = radius * cos(theta)
		point.y = radius * sin(theta)
		points.append(point)
