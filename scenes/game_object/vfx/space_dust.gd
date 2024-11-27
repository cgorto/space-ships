class_name SpaceDust extends Node3D

@export var min_particles: int = 200
@export var max_particles: int = 500
@export var particle_mesh: MeshInstance3D
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@export var base_length: float = 1.2


var current_velocity: float = 0


func _process(delta: float) -> void:
	var vel_remap: float = remap(current_velocity,0,500,0,1)
	if vel_remap < 0.5:
		gpu_particles_3d.emitting = false
	else:
		gpu_particles_3d.emitting = true
		gpu_particles_3d.amount = remap(vel_remap,0.5,1.0,min_particles,max_particles)
	(particle_mesh.mesh as BoxMesh).size.z = base_length * current_velocity * 0.03
