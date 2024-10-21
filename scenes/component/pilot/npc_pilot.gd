class_name NPCPilot extends Pilot

var think_counter: float = 0
var think_delay: float

@onready var preferred_avoid: Vector3 = Util.uniform_random_vector() * 200
@onready var seed: float = randf_range(0,1000)



func dogfight(delta: float) -> void:
	if targeting.target == null:
		return
	var distance_squared: float = global_position.distance_squared_to(targeting.target.global_position)
	if distance_squared < 1000:
		turn_towards_point(targeting.target.global_position + preferred_avoid, delta)
		throttle = 0.4
	else:
		#THIS NEEDS TO BE CHANGED, PILOT PROBABLY NEEDS A REFERENCE TO EITHER OWN SHIP OR OWN WEAPONS
		var target_point:Vector3 = Util.calculate_lead(owner,targeting.target,100)
		var turn_strength: float = 1 #generate noise here
		turn_towards_point(target_point, delta)
