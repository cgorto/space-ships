extends Node3D

@onready var box: PackedScene = preload("res://scenes/csg_mesh_3d.tscn")

func _ready() -> void:
	var box_scale: int = 800
	for i in 1500:
		var new_box: Node3D = box.instantiate()
		new_box.position = Vector3(box_scale *randf() -box_scale*0.5, box_scale *randf() -box_scale*0.5, box_scale *randf() -box_scale*0.5)
		add_child(new_box)
