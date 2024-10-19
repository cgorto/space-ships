class_name PID extends RefCounted

var p_factor: float
var i_factor: float
var d_factor: float

var integral: float
var last_error: float

var print_counter: float = 0

func _init(_p_factor: float, _i_factor: float, _d_factor: float) -> void:
	p_factor = _p_factor
	i_factor = _i_factor
	d_factor = _d_factor
	

func update(set_point: float, actual: float, delta: float) -> float:
	var present: float = set_point - actual
	if is_zero_approx(present):
		present = 0
	integral += present * delta
	var deriv: float = (present - last_error) / delta
	last_error = present
	return present * p_factor + integral * i_factor + deriv * d_factor
