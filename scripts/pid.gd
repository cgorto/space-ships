class_name PID extends RefCounted

var p_factor: float
var i_factor: float
var d_factor: float 
var integral_saturation: float = 1

var integral: float
var last_error: float

var print_counter: float = 0

func _init(_p_factor: float, _i_factor: float, _d_factor: float) -> void:
	p_factor = _p_factor
	i_factor = _i_factor
	d_factor = _d_factor
	
	
#Sort of big issue with I, if you turn in one direction for a long time, your I will add up such that if you turn in a different direction, you will still be turning towards the
#previous direction for a while. Maybe reset I if the sign of the error is different than the last error?

func update(set_point: float, actual: float, delta: float) -> float:
	var present: float = set_point - actual
	if is_zero_approx(present):
		present = 0
	if !(last_error * present > 1):
		integral *= 0.5
	integral = clampf(integral + (present * delta), -integral_saturation,integral_saturation)
	var deriv: float = (present - last_error) / delta
	last_error = present
	return present * p_factor + integral * i_factor + deriv * d_factor

func set_p(new_p:float) -> void:
	p_factor = new_p
func set_i(new_i:float) -> void:
	i_factor = new_i
func set_d(new_d:float) -> void:
	d_factor = new_d
