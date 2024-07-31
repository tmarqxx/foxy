extends Resource
class_name JumpData

@export_range(0.0, 100.0) var height: float = 0.0:
	set(value):
		height = value
		velocity = _calc_velocity(height, time_to_peak)
		gravity = _calc_gravity(height, time_to_peak)
		fall_gravity = _calc_gravity(height, time_to_fall)
@export_range(0.0, 5.0) var time_to_peak: float = 0.0:
	set(value):
		time_to_peak = value
		velocity = _calc_velocity(height, time_to_peak)
		gravity = _calc_gravity(height, time_to_peak)
@export_range(0.0, 5.0) var time_to_fall: float = 0.0:
	set(value):
		time_to_fall = value
		fall_gravity = _calc_gravity(height, time_to_fall)

var velocity: float = 0.0
var gravity: float = 0.0
var fall_gravity: float = 0.0

#func _init():
	#velocity = 0.0
	#gravity = 0.0
	#fall_gravity = 0.0

func _calc_velocity(_height: float, _time: float) -> float:
	return (2.0 * _height) / _time

func _calc_gravity(_height: float, _time: float) -> float:
	return (-2.0 * _height) / (_time * _time)
