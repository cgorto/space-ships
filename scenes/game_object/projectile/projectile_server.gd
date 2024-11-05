extends Node

var multimesh_pools: Dictionary[String,MultiMeshInstance3D] = {}
var active_projectiles: Array[ProjectileData]

const MAX_PROJECTILES_PER_POOL = 10000

class ProjectileData:
	var body: RID
	var shape: RID
	var multimesh: MultiMesh
	var instance_id: int
	var velocity: Vector3
	var damage: float
	var faction: int
	var start_pos: Vector3
	var max_range: float
	

func _physics_process(delta: float) -> void:
	var i: int = active_projectiles.size() - 1
	while i >= 0:
		var proj: ProjectileData = active_projectiles[i]

		var current_transform: Transform3D = PhysicsServer3D.body_get_state(proj.body, PhysicsServer3D.BODY_STATE_TRANSFORM)
		var new_position: Vector3 = current_transform.origin + proj.velocity * delta
		current_transform.origin = new_position
		
		PhysicsServer3D.body_set_state(proj.body, PhysicsServer3D.BODY_STATE_TRANSFORM, current_transform)
		proj.multimesh.set_instance_transform(proj.instance_id, current_transform)
		
		if new_position.distance_to(proj.start_pos) > proj.max_range:
			destroy_projectile(i)
		
		i -= 1

func get_or_create_multimesh_pool(mesh_path:String, mesh: Mesh) -> MultiMeshInstance3D:
	if mesh_path in multimesh_pools:
		return multimesh_pools[mesh_path]
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_custom_data = true
	multimesh.instance_count = MAX_PROJECTILES_PER_POOL
	multimesh.mesh = mesh
	
	var multimesh_instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	multimesh_instance.multimesh = multimesh
	
	for i in MAX_PROJECTILES_PER_POOL:
		multimesh.set_instance_custom_data(i, Color(1,1,1,0))
	add_child(multimesh_instance)
	multimesh_pools[mesh_path] = multimesh_instance
	return multimesh_instance

func find_available_instance_id(multimesh: MultiMesh) -> int:
	for i in MAX_PROJECTILES_PER_POOL: #THIS MAY BE AWFUL
		if multimesh.get_instance_custom_data(i).a < 0.5:
			return i
	return -1

func spawn_projectile(
	mesh_resource: Mesh, start_transform: Transform3D, target_pos: Vector3,
	speed: float, damage: int, faction: int, max_range: float
	) -> void: #Implement faction later
	
	var mesh_path: String = mesh_resource.resource_path
	var multimesh_instance: MultiMeshInstance3D = get_or_create_multimesh_pool(mesh_path,mesh_resource)
	
	var body: RID = PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(body, PhysicsServer3D.BODY_MODE_KINEMATIC)
	
	var shape: SphereShape3D = SphereShape3D.new()
	shape.radius = 0.5
	var shape_rid: RID = PhysicsServer3D.sphere_shape_create()
	PhysicsServer3D.shape_set_data(shape_rid,shape)
	
	PhysicsServer3D.body_add_shape(body,shape)
	PhysicsServer3D.body_set_collision_layer(body,0b1000)
	PhysicsServer3D.body_set_collision_mask(body, 0b0)
	
	PhysicsServer3D.body_set_state(body,PhysicsServer3D.BODY_STATE_TRANSFORM,start_transform)
	PhysicsServer3D.body_set_space(body, get_tree().root.world_3d.space)
	
	var direction: Vector3 = (target_pos - start_transform.origin).normalized()
	var velocity: Vector3 = direction * speed
	
	var instance_id: int = find_available_instance_id(multimesh_instance.multimesh)
	if instance_id == -1:
		return
		
	var proj_data: ProjectileData = ProjectileData.new()
	proj_data.body = body
	proj_data.shape = shape_rid
	proj_data.multimesh = multimesh_instance.multimesh
	proj_data.instance_id = instance_id
	proj_data.velocity = velocity
	proj_data.damage = damage
	proj_data.faction = faction
	proj_data.start_pos = start_transform.origin
	proj_data.max_range = max_range
	
	active_projectiles.append(proj_data)
	
	multimesh_instance.multimesh.set_instance_transform(instance_id,start_transform)
	
	
func destroy_projectile(index: int) -> void:
	var proj:ProjectileData = active_projectiles[index]
	
	PhysicsServer3D.free_rid(proj.shape)
	PhysicsServer3D.free_rid(proj.body)
	proj.multimesh.set_instance_custom_data(proj.instance_id,Color(1,1,1,0))
	
	active_projectiles.remove_at(index)
	
