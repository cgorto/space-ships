class_name NPCPilot extends Pilot

const MIN_ENGAGE_DISTANCE: float = 100.0
const MAX_FIRING_DISTANCE: float = 1000.0
const FIRING_ANGLE_THRESHOLD: float = 0.1
const CHASE_ANGLE_THRESHOLD: float = 1.5708
const MIN_THROTTLE: float = 0.33
const MAX_THROTTLE: float = 0.9


var think_counter: float = 0
var think_delay: float
@export var fire_chance: float = 1

@onready var preferred_avoid: Vector3 = Util.uniform_random_vector() * 200

var target: Pilot
var potential_targets: Array[Node3D] = []

var noise: FastNoiseLite = FastNoiseLite.new()
var last_noise_time: int = 0
var cached_noise_value: float = 0.0
const NOISE_UPDATE_INTERVAL: int = 50

var cached_direction: Vector3
var cached_distance: float



func _ready() -> void:
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	
func _process(delta: float) -> void:
	think_counter +=delta
	if target == null:
		if think_counter >= think_delay:
			update_targeting()
	update_combat(delta)
	if is_firing:
		weapon.shoot()
	


#func dogfight(delta: float) -> void:
	#if target == null:
		#is_firing = false
		#return
	#var distance: float = global_position.distance_to(target.global_position)
	#if distance < 100:
		#turn_towards_point(target.global_position + preferred_avoid, delta)
		#throttle = 0.4
		#is_firing = false
	#else:
		##var relative_pos: Vector3 = own_ship.global_position - target.own_ship.global_position
		##var relative_vel: Vector3 = own_ship.linear_velocity - target.own_ship.linear_velocity
		##var lead_time: float = Util.calculate_lead(relative_pos,relative_vel,-weapon.bullet_spawner.proj_speed)
		##var target_point: Vector3 = target.global_position + (target.own_ship.linear_velocity * lead_time)
		#
		#var target_point: Vector3 = Util.calculate_lead(own_ship,target.own_ship,weapon.projectile_speed)
#
		#var turn_strength: float = (noise.get_noise_1d(rand_seed + Time.get_ticks_msec()) + 1) / 2
		#turn_towards_point(target_point, delta, turn_strength)
		#var angle_to_target: float = -global_basis.z.angle_to(target_point)
		#
		#is_firing = angle_to_target < 0.1 && is_fire_allowed() && distance < 400
		#if (-global_basis.z).angle_to(-target.global_basis.z) < 90:
			#throttle = clamp(remap(distance,50,1500,6,.8),.33,.9)
			##throttle = 0.8
		#else:
			#throttle = 0.85

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

func update_combat(delta: float) -> void:
	if !is_instance_valid(target):
		target = null
		is_firing = false
		return
	
	cached_distance = global_position.distance_to(target.global_position)
	
	if cached_distance < MIN_ENGAGE_DISTANCE:
		handle_close_combat(delta)
	else:
		handle_ranged_combat(delta)

func handle_close_combat(delta:float) -> void:
	turn_towards_point(target.global_position + preferred_avoid, delta)
	throttle = 0.4
	is_firing = false
	
func handle_ranged_combat(delta: float) -> void:
	var target_point: Vector3 = Util.calculate_lead(
		own_ship,
		target.own_ship,
		weapon.projectile_speed
	)
	
	var turn_strength: float = get_cached_noise_value()
	turn_towards_point(target_point, delta)
	
	cached_direction = - global_basis.z
	var angle_to_target: float = cached_direction.angle_to(target_point)
	
	is_firing = (
		angle_to_target < FIRING_ANGLE_THRESHOLD &&
		should_fire() &&
		cached_distance < MAX_FIRING_DISTANCE
	)
	
	if cached_direction.angle_to(-target.global_basis.z) < CHASE_ANGLE_THRESHOLD:
		throttle = calculate_chase_throttle()
	else:
		throttle = 0.85
	
func calculate_chase_throttle() -> float:
	return clamp(
		remap(cached_distance, 50.0, 1500.0,6.0,0.8),
		MIN_THROTTLE,
		MAX_THROTTLE
	)

func should_fire() -> bool:
	return get_cached_noise_value() < fire_chance
	
func get_cached_noise_value() -> float:
	var current_time: int = Time.get_ticks_msec()
	if current_time - last_noise_time > NOISE_UPDATE_INTERVAL:
		cached_noise_value = (noise.get_noise_1d(current_time) + 1.0) * 0.5
		last_noise_time = current_time
	return cached_noise_value
	
func update_targeting() -> void:
	think_delay = randf_range(1.0,2.0)
	think_counter = 0.0
	
	target = get_target()
	
