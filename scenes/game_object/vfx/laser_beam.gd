class_name LaserBeam extends Node3D

@onready var line: Line3D = $Line3D
@onready var timer: Timer = $Timer

var offset: Vector3 = Vector3.ZERO
var target_pos: Vector3

func _ready() -> void:
	line.points.append(offset)
	line.points.append(target_pos) 
	
func _process(delta: float) -> void:
	line.points[1] = target_pos + global_position
	line.rebuild()


func _on_timer_timeout() -> void:
	queue_free()
