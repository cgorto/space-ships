class_name Ship extends RigidBody3D

@onready var ship_physics: ShipPhysics = $ShipPhysics
@onready var hp: HealthComponent = $HealthComponent
@onready var hurtbox: Hurtbox = $Hurtbox

@export var pilot: Pilot

 

func _process(_delta: float) -> void:
	ship_physics.set_physics_input(
		Vector3(
			pilot.strafe, 
			0, 
			-pilot.throttle * pilot.speed_multiplier
		),
		Vector3(
			pilot.pitch * pilot.turn_multiplier,
			pilot.yaw * pilot.turn_multiplier,
			pilot.roll
		)
	)
