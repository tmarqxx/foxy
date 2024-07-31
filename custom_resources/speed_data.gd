extends Resource
class_name SpeedData

@export_range(0.0, 100.0) var max_speed: float:
	set(value):
		max_speed = value
		acceleration_rate = _calc_acceleration(max_speed, time_to_max_speed)
		deceleration_rate = _calc_acceleration(max_speed, time_to_stop)
@export_range(0.0, 5.0) var time_to_max_speed: float:
	set(value):
		time_to_max_speed = value
		acceleration_rate = _calc_acceleration(max_speed, time_to_max_speed)
@export_range(0.0, 5.0) var time_to_stop: float:
	set(value):
		time_to_stop = value
		deceleration_rate = _calc_acceleration(max_speed, time_to_stop)

var acceleration_rate: float = 0.0
var deceleration_rate: float = 0.0

func _init():
	acceleration_rate = 0.0
	deceleration_rate = 0.0

func _calc_acceleration(speed: float, time: float) -> float:
	return speed / time
