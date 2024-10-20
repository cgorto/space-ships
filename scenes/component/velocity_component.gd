class_name VelocityComponent extends Node

@export var max_speed: int = 50
@export var acceleration: float = 5

var velocity: Vector3 = Vector3.ZERO


func accelerate_in_direction(direction: Vector3) -> void:
	
	var desired_velocity:Vector3 = direction.normalized() * max_speed
	velocity = velocity.slerp(desired_velocity, 1 - exp(-acceleration *get_physics_process_delta_time()))
	
func decelerate() -> void:
	accelerate_in_direction(Vector3.ZERO)

func move(to_move: Node3D) -> void:
	if to_move is CharacterBody3D:
		to_move.velocity = velocity
		to_move.move_and_slide()
		velocity = to_move.velocity
	else:
		to_move.position += velocity * get_physics_process_delta_time()
