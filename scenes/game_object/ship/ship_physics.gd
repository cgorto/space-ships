class_name ShipPhysics extends Node

#X: Lateral, Y: Vertical, Z: Longitudinal
var linear_force: Vector3 = Vector3(100,100,100)
#X: Pitch, Y: Yaw, Z: Roll
var angular_force: Vector3 = Vector3(deg_to_rad(100),deg_to_rad(100),deg_to_rad(100))

var reverse_multiplier: float = 1
var force_multiplier: float = 100

var applied_linear_force: Vector3 = Vector3.ZERO
var applied_angular_force: Vector3 = Vector3.ZERO

@export var rigid_body: RigidBody3D

func _physics_process(delta: float) -> void:
	if rigid_body != null:
		rigid_body.apply_force(rigid_body.transform.basis * (applied_linear_force * force_multiplier))
		rigid_body.apply_torque(rigid_body.transform.basis * (applied_angular_force * force_multiplier))

func set_physics_input(linear_input: Vector3, angular_input: Vector3) -> void:
	applied_linear_force = linear_force * linear_input
	applied_angular_force = angular_force * angular_input
