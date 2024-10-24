extends Node3D

@onready var box: PackedScene = preload("res://scenes/csg_mesh_3d.tscn")
@onready var enemy: PackedScene = preload("res://scenes/game_object/npc_ship.tscn")


func _ready() -> void:
	var box_scale: int = 2000
	for i in 2000:
		var new_box: Node3D = box.instantiate()
		new_box.position = Vector3(box_scale *randf() -box_scale*0.5, box_scale *randf() -box_scale*0.5, box_scale *randf() -box_scale*0.5)
		add_child(new_box)
	for i in 300:
		var new_npc: NPCShip = enemy.instantiate()
		new_npc.position = Vector3(box_scale *randf() -box_scale*0.5, box_scale *randf() -box_scale*0.5, box_scale *randf() -box_scale*0.5)
		add_child(new_npc)
		new_npc.pilot.faction = Pilot.FACTION.FRIENDLY if randf() < 0.5 else Pilot.FACTION.ENEMY


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
			get_tree().quit()
