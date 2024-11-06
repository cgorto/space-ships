class_name Ship extends RigidBody3D

@onready var ship_physics: ShipPhysics = $ShipPhysics
@onready var hp: HealthComponent = $HealthComponent

@export var pilot: Pilot

 

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
