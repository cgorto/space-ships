class_name Turret extends Node3D

@onready var turret_base: Node3D = $TurretBase
@onready var barrels: Node3D = $TurretBase/Barrels

@export_group("Movement Speeds")
@export var elevation_speed: float = 5.0
@export var traverse_speed: float = 5.0

@export_group("Rotation Limits")
@export var max_elevation: float = deg_to_rad(80)  # Up
@export var max_depression: float = deg_to_rad(80) # Down
@export var is_limited_traverse: bool = false
@export_range(0, PI) var traverse_limit: float = deg_to_rad(5)

@export_group("Targeting")
@export var target: Node3D = null
@export var aim_threshold: float = deg_to_rad(50)  # About 1 degree of accuracy

@export_group("Weapon")
@export var weapon: Node3D

var is_idle: bool = true


func _process(delta: float) -> void:
	#if is_idle:
		#return_to_idle(delta)

	track_target(delta)

func track_target(delta: float) -> void:
	if not is_instance_valid(target):
		return
	var target_pos: Vector3 = to_local(target.global_position)
	if target is Ship:
		var time_to_hit: float = Util.solve_intercept(target.global_position - global_position, target.linear_velocity,weapon.projectile_speed)
		var lead: Vector3 = target.global_position + (target.linear_velocity * time_to_hit)
		target_pos = to_local(lead)
	traverse(target_pos, delta)
	elevate(target_pos, delta)
	if is_aimed():
		weapon.shoot()
	
	
	


func traverse(target_pos: Vector3, delta: float) -> void:
	var target_angle: float = atan2(-target_pos.x, -target_pos.z)
	
	if is_limited_traverse:
		target_angle = clampf(target_angle, -traverse_limit, traverse_limit)
	var current_angle: float = turret_base.rotation.y
	turret_base.rotation.y = Util.move_angle(current_angle, target_angle, traverse_speed, delta)
	
func elevate(target_pos: Vector3, delta: float) -> void:
	var xz_distance: float = Vector2(target_pos.x, target_pos.z).length()
	var target_angle: float = atan2(target_pos.y, xz_distance)
	
	target_angle = clampf(target_angle, -max_depression, max_elevation)
	var current_angle: float = barrels.rotation.x
	
	barrels.rotation.x = Util.move_angle(current_angle, target_angle, elevation_speed, delta)

func return_to_idle(delta: float) -> void:
	pass

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
#func is_at_rest() -> bool:
	#return is_zero_approx(current_traverse) and is_zero_approx(current_elevation)

func get_angle_to_target() -> float:
	if !is_instance_valid(target):
		return 999.9
	
	var to_target: Vector3 = target.global_position - global_position
	
	if target is Ship:
		var time_to_hit: float = Util.solve_intercept(target.global_position - global_position, target.linear_velocity,weapon.projectile_speed)
		var lead: Vector3 = target.global_position + (target.linear_velocity * time_to_hit)
		to_target = lead - global_position
	return (-barrels.global_transform.basis.z).angle_to(to_target)

func is_aimed() -> bool:
	return get_angle_to_target() < aim_threshold
