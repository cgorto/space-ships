extends Node3D
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
var extent: float = 500.0
func _ready() -> void:
	gpu_particles_3d.draw_pass_1 = _create_particle_mesh()

func _create_particle_mesh() -> Mesh:
	# Create a simple quad mesh for particles
	var arrays: = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var verts: = PackedVector3Array()
	var uvs: = PackedVector2Array()
	var colors: = PackedColorArray()
	
	# Create quad vertices
	verts.push_back(Vector3(-0.5, 0.0, 0.0))
	verts.push_back(Vector3(0.5, 0.0, 0.0))
	verts.push_back(Vector3(-0.5, 1.0, 0.0))
	verts.push_back(Vector3(0.5, 1.0, 0.0))
	
	# UVs
	uvs.push_back(Vector2(0, 0))
	uvs.push_back(Vector2(1, 0))
	uvs.push_back(Vector2(0, 1))
	uvs.push_back(Vector2(1, 1))
	
	# Base color (will be modified by shader)
	for i in range(4):
		colors.push_back(Color(1, 1, 1, 1))
	
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = colors
	
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	return mesh

func _process(delta: float) -> void:
	if gpu_particles_3d.material_override:
		var camera: Camera3D = get_viewport().get_camera_3d()
		if camera:
			gpu_particles_3d.set_instance_shader_parameter("camera_position", camera.global_position)
			gpu_particles_3d.set_instance_shader_parameter("extent", extent)
