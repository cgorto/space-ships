class_name Pilot extends Node3D

@export var bank_limit: float = deg_to_rad(50)

var pitch: float
var yaw: float
var roll: float
var strafe: float
var throttle: float


@export var pitch_pid_params: Vector3 = Vector3(1.5, 1, 0.5)
@export var yaw_pid_params: Vector3 = Vector3(1.5, 1, 0.5)
@export var roll_pid_params: Vector3 = Vector3(0.7, 0.5, 1.0)


var pitch_pid: PID = PID.new(pitch_pid_params.x, pitch_pid_params.y, pitch_pid_params.z)
var yaw_pid: PID = PID.new(yaw_pid_params.x, yaw_pid_params.y, yaw_pid_params.z)
var roll_pid: PID = PID.new(roll_pid_params.x, roll_pid_params.y, roll_pid_params.z)

@export var throttle_speed: float = 0.5

enum FACTION {FRIENDLY, ENEMY}
@export var faction: FACTION
@export var own_ship: RigidBody3D
@export var weapon: Node3D

var is_firing: bool = false


func bank_ship_relative_to_up(mouse_pos: Vector2, up: Vector3, delta:float) -> void:
	var bank_influence: float = (mouse_pos.x - (get_viewport().size.x * 0.5)) / (get_viewport().size.x * 0.5)
	bank_influence = clampf(bank_influence,-1,1)
	bank_influence *= throttle
	
	var bank_target: float = - bank_influence * bank_limit
	var bank_current: float = global_transform.basis.y.signed_angle_to(up, -global_transform.basis.z)
	var bank: float = roll_pid.update(bank_target, bank_current, delta)
	bank = clampf(bank, -1,1)
	
	roll = bank



func turn_towards_point(to: Vector3, delta: float, turn_strength: float = 1) -> void:
	var local_to: Vector3 = to_local(to).normalized()
	pitch = clampf(pitch_pid.update(0, -local_to.y, delta), -1, 1) * turn_strength
	yaw = clampf(yaw_pid.update(0, local_to.x, delta), -1,1) * turn_strength


func set_faction(new_faction: FACTION) -> void:
	faction = new_faction
	
