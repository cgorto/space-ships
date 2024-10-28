class_name NPCShip extends RigidBody3D

@onready var ship_physics: ShipPhysics = $ShipPhysics
@onready var pilot: Pilot = $Pilot
@onready var hp: HealthComponent = $HealthComponent
@onready var hit_sound: RandomStreamPlayerComponent = $RandomStreamPlayerComponent

var velocity: Vector3

func _ready() -> void:
	hp.health_decreased.connect(on_damaged)

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

func on_damaged() -> void:
	hit_sound.play_random()
