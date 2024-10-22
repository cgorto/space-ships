class_name Pilot extends Node3D

@export var bank_limit: float = deg_to_rad(50)

var pitch: float
var yaw: float
var roll: float
var strafe: float
var throttle: float


var pitch_pid: PID = PID.new(1.5, 1, 0.5)
var yaw_pid: PID = PID.new(1.5, 1, 0.5)
var roll_pid: PID = PID.new(0.3, 1.0, 1.0)

@export var throttle_speed: float = 0.5

enum FACTION {FRIENDLY, ENEMY}
@export var faction: FACTION
@export var own_ship: Node3D
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
