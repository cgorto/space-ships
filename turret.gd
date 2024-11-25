class_name Turret extends Node3D

@onready var turret_base: Node3D = $TurretBase
@onready var barrels: Node3D = $TurretBase/Barrels

@export_group("Movement Speeds")
@export var elevation_speed: float = 2.0
@export var traverse_speed: float = 2.0

@export_group("Rotation Limits")
@export var max_elevation: float = deg_to_rad(45)  # Up
@export var max_depression: float = deg_to_rad(10) # Down
@export var is_limited_traverse: bool = false
@export_range(0, PI) var traverse_limit: float = deg_to_rad(60)

@export_group("Targeting")
@export var target: Node3D = null
@export var aim_threshold: float = deg_to_rad(5)  # About 1 degree of accuracy

var is_idle: bool = true
var current_elevation: float = 0.0
var current_traverse: float = 0.0

func _process(delta: float) -> void:
	if is_idle:
		return_to_idle(delta)
	else:
		track_target(delta)

func track_target(delta: float) -> void:
	pass

func return_to_idle(delta: float) -> void:
	# Smoothly return to neutral position
	current_traverse = Util.move_float(current_traverse, 0.0, traverse_speed, delta)
	current_elevation = Util.move_float(current_elevation, 0.0, elevation_speed, delta)
	
	turret_base.rotation.y = current_traverse
	barrels.rotation.x = current_elevation

func calculate_target_traverse(to_target: Vector3) -> float:
	# Project the vector onto the XZ plane for traverse calculation
	var xz_target: Vector3 = Vector3(to_target.x, 0, to_target.z).normalized()
	var forward: Vector3 = -global_transform.basis.z
	var xz_forward: Vector3 = Vector3(forward.x, 0, forward.z).normalized()
	
	return xz_forward.signed_angle_to(xz_target, Vector3.UP)

func calculate_target_elevation(local_target: Vector3) -> float:
	# Calculate elevation using atan2 for more accurate angles
	var horizontal_distance: float = sqrt(local_target.x * local_target.x + local_target.z * local_target.z)
	return -atan2(local_target.y, horizontal_distance)

func set_target(new_target: Node3D) -> void:
	target = new_target
	is_idle = false

func set_idle(idle: bool) -> void:
	is_idle = idle

# Optional - add these utility functions if you need them
func is_at_rest() -> bool:
	return is_zero_approx(current_traverse) and is_zero_approx(current_elevation)

func get_angle_to_target() -> float:
	if !is_instance_valid(target):
		return 0.0
	var to_target: Vector3 = target.global_position - global_position
	return barrels.global_transform.basis.z.angle_to(to_target)

func is_aimed() -> bool:
	return !is_idle and get_angle_to_target() < aim_threshold
