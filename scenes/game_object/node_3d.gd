class_name NpcShipInput extends Node3D

@export var bank_limit: float = deg_to_rad(50)


@export var target:Node3D

@export_range(-1,1) var pitch: float
@export_range(-1,1) var yaw: float
@export_range(-1,1) var roll: float
@export_range(-1,1) var strafe: float
@export_range(0,1) var throttle: float


var pitch_pid: PID = PID.new(1.5, 1, 0.5)
var yaw_pid: PID = PID.new(1.5, 1, 0.5)
var roll_pid: PID = PID.new(0.3, 1.0, 1.0)

@export var throttle_speed: float = 0.5



func _process(delta: float) -> void:
	
	auto_pilot(target.global_position,delta)



func auto_pilot(to: Vector3, delta:float) -> void:

	turn_towards_point(to, delta)
	


func turn_towards_point(to: Vector3, delta: float) -> void:
	# ============= v SHOULD HAVE PARITY v =======================
	var local_to: Vector3 = to_local(to).normalized()
	#var local_to: Vector3 = global_transform.inverse() * (to - global_position)

	
	
	pitch = clampf(pitch_pid.update(0, -local_to.y, delta), -1, 1)
	yaw = clampf(yaw_pid.update(0, local_to.x, delta), -1,1)
	roll = clampf(roll_pid.update(0, local_to.z, delta),-1,1)
	# ============= ^ SHOULD HAVE PARITY ^ =======================
