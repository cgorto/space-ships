class_name ShipPhysics extends Node

@export_group("Physics Properties")
@export var mass: float = 150.0
@export var linear_drag: float = 155.0
@export var angular_drag: Vector3 = Vector3(200.0, 200.0, 200.0)
@export var angular_inertia: Vector3 = Vector3(12500.0, 12500.0, 12500.0)

@export_group("Force Properties")
@export var steering_torque: Vector3 = Vector3(1200.0, 1200.0, 1200.0)
@export var thrust_force: float = 80000.0
@export var booster_force: float = 12000.0
@export var strafe_force: float = 40000.0
@export var reverse_fraction: float = 0.5
@export var bank_limit: float = 80.0

var applied_linear_force: Vector3 = Vector3.ZERO
var applied_angular_force: Vector3 = Vector3.ZERO

@export var rigid_body: RigidBody3D

func configure_rigidbody() -> void:
	rigid_body.mass = mass
	rigid_body.inertia = angular_inertia


func _physics_process(_delta: float) -> void:
	if rigid_body == null:
		return
	
	rigid_body.apply_central_force(rigid_body.transform.basis * applied_linear_force)
	rigid_body.apply_torque(rigid_body.transform.basis * applied_angular_force)
	apply_drag_forces()

func set_physics_input(linear_input: Vector3, angular_input: Vector3) -> void:
	applied_linear_force = Vector3(
		linear_input.x * strafe_force,
		linear_input.y * strafe_force,
		linear_input.z * thrust_force
	)
	applied_angular_force = angular_input * steering_torque


func apply_drag_forces() -> void:
	# Linear drag
	var drag_force: Vector3 = -rigid_body.linear_velocity * linear_drag
	rigid_body.apply_central_force(drag_force)
	
	# Angular drag - transform to local space
	var local_angular_velocity: Vector3 = rigid_body.transform.basis.inverse() * rigid_body.angular_velocity
	var local_angular_drag: Vector3 = Vector3(
		-local_angular_velocity.x * angular_drag.x,
		-local_angular_velocity.y * angular_drag.y,
		-local_angular_velocity.z * angular_drag.z
	)
	var angular_drag_torque: Vector3 = rigid_body.transform.basis * local_angular_drag
	rigid_body.apply_torque(angular_drag_torque)
