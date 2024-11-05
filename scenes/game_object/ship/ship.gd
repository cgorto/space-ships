class_name Ship extends RigidBody3D

@onready var ship_physics: ShipPhysics = $ShipPhysics
@onready var hp: HealthComponent = $HealthComponent

@export var pilot: Pilot
@export var ship_stats: ShipData

func _ready() -> void:
	if ship_stats != null:
		set_stats(ship_stats)

func _process(_delta: float) -> void:
	ship_physics.set_physics_input(
		Vector3(
			pilot.strafe, 
			0, 
			-pilot.throttle
		),
		Vector3(
			pilot.pitch,
			pilot.yaw,
			pilot.roll
		)
	)

func set_stats(ship_data:ShipData) -> void:
	hp.set_max_health(ship_data.health)
	mass = ship_data.mass
	ship_physics.linear_force = ship_data.speed
	ship_physics.angular_force = Vector3(deg_to_rad(ship_data.torque.x),deg_to_rad(ship_data.torque.y),deg_to_rad(ship_data.torque.z))
	linear_damp = ship_data.linear_drag
	angular_damp = ship_data.linear_drag
	
	if pilot != null:
		pilot.throttle_speed = ship_data.accel
