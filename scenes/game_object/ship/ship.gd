extends RigidBody3D

@onready var ship_physics: ShipPhysics = $ShipPhysics
@onready var ship_input: ShipInput = $ShipInput

var velocity: Vector3

func _process(delta: float) -> void:
	ship_physics.set_physics_input(Vector3(ship_input.strafe, 0, -ship_input.throttle),Vector3(ship_input.pitch,ship_input.yaw,ship_input.roll))
