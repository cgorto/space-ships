extends Node3D

@export var camera_rig: CameraRig

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("player_cam"):
		camera_rig.ship = get_tree().get_first_node_in_group("player")
	elif Input.is_action_just_pressed("rand_cam"):
		camera_rig.ship = get_tree().get_nodes_in_group("target").pick_random()
