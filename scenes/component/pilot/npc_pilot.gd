class_name NPCPilot extends Pilot

var think_counter: float = 0
var think_delay: float
@export var fire_chance: float = 0.4

@onready var preferred_avoid: Vector3 = Util.uniform_random_vector() * 200
@onready var rand_seed: int = randi_range(0,1000)

var target: Pilot
var potential_targets: Array[Node3D] = []

var noise: FastNoiseLite = FastNoiseLite.new()

func _ready() -> void:
	noise.seed = rand_seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
func _process(delta: float) -> void:
	think_counter +=delta
	run_targeting()
	dogfight(delta)
	if is_firing:
		weapon.shoot()
	
func is_fire_allowed() -> bool:
	var noise_value: float = (noise.get_noise_1d(rand_seed + Time.get_ticks_msec()) + 1) / 2
	return noise_value < fire_chance

func dogfight(delta: float) -> void:
	if target == null:
		is_firing = false
		return
	var distance: float = global_position.distance_to(target.global_position)
	if distance < 100:
		turn_towards_point(target.global_position + preferred_avoid, delta)
		throttle = 0.4
		is_firing = false
	else:
		var relative_pos: Vector3 = own_ship.global_position - target.own_ship.global_position
		var relative_vel: Vector3 = own_ship.linear_velocity - target.own_ship.linear_velocity
		var lead_time: float = Util.calculate_lead(relative_pos,relative_vel,-weapon.bullet_spawner.proj_speed)
		var target_point: Vector3 = target.global_position + (target.own_ship.linear_velocity * lead_time)

		var turn_strength: float = (noise.get_noise_1d(rand_seed + Time.get_ticks_msec()) + 1) / 2
		turn_towards_point(target_point, delta, turn_strength)
		var angle_to_target: float = -global_basis.z.angle_to(target_point)
		
		is_firing = angle_to_target < 0.1 && is_fire_allowed() && distance < 400
		if (-global_basis.z).angle_to(-target.global_basis.z) < 90:
			throttle = clamp(remap(distance,50,1500,6,.8),.33,.9)
			#throttle = 0.8
		else:
			throttle = 0.85

func run_targeting() -> void:
	if think_counter > think_delay:
		think_delay = randf_range(1,2)
		if target == null:
			target = get_target()


func get_target() -> Pilot:
	potential_targets.clear()
	for tar in get_tree().get_nodes_in_group("target"):
		var current_target: Pilot = tar as Pilot
		if current_target.faction != faction:
			potential_targets.append(current_target)
	return potential_targets.pick_random() if potential_targets.size() > 0 else null
