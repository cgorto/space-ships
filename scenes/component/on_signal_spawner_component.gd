class_name OnSignalSpawnerComponent extends Node3D

@export var on_signal_scene: PackedScene
	
func on_signal(_thing: Node) -> void:
	if on_signal_scene == null:
		return
	var to_add: Node3D = on_signal_scene.instantiate()
	var main:= get_tree().current_scene
	to_add.position = global_position
	main.add_child(to_add)
