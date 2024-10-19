extends Node3D

@onready var box: PackedScene = preload("res://scenes/csg_mesh_3d.tscn")

func _ready() -> void:
	var box_scale: int = 500
	for i in 500:
		var new_box: Node3D = box.instantiate()
		new_box.position = Vector3(500 *randf() -250, 500 *randf() -250, 500 *randf() -250)
		add_child(new_box)
