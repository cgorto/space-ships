extends Node3D

@onready var box: PackedScene = preload("res://scenes/csg_mesh_3d.tscn")
@export var enemy: PackedScene
@export var turret: PackedScene

@export var box_number: int = 1000
@export var ship_number: int = 50


func _ready() -> void:
	var box_scale: int = 5000
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	for i in box_number:
		var new_box: Node3D = box.instantiate()
		new_box.position = Vector3(box_scale *randf() -box_scale*0.5, box_scale *randf() -box_scale*0.5, box_scale *randf() -box_scale*0.5)
		add_child(new_box)
	for i in ship_number:
		var new_npc: Ship = enemy.instantiate()
		new_npc.position = Vector3(box_scale *randf() -box_scale*0.5, box_scale *randf() -box_scale*0.5, box_scale *randf() -box_scale*0.5)
		add_child(new_npc)
		new_npc.pilot.faction = Pilot.FACTION.FRIENDLY if randf() < 0.5 else Pilot.FACTION.ENEMY

		


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
			get_tree().quit()
