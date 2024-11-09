class_name Thrust extends Node3D

@export var pilot: Pilot
@export_group("Thrust Properties")
@export var base_radius: float = 1
@export var min_length: float = 0.1
@export var max_length: float = 4

@onready var thrust_mesh: MeshInstance3D = $ThrustMesh

func _ready() -> void:
	if pilot == null:
		return
	pilot.throttle_changed.connect(_on_throttle_changed)
	(thrust_mesh.mesh as CylinderMesh).bottom_radius = base_radius

func _on_throttle_changed(new_throttle: float) -> void:
	var new_height: float = remap(new_throttle,0,1,min_length,max_length)
	(thrust_mesh.mesh as CylinderMesh).height = new_height
	thrust_mesh.position.z = new_height / 2
	thrust_mesh.material_override.set("shader_parameter/model_height",new_height)
