extends Node3D

@export var health_component: HealthComponent
@export var on_death_scene: PackedScene

func _ready() -> void:
	health_component.died.connect(on_death)
	
func on_death(_thing: Node) -> void:
	if on_death_scene == null:
		return
	var to_add: Node3D = on_death_scene.instantiate()
	var main:= get_tree().current_scene
	to_add.position = global_position
	main.add_child(to_add)
