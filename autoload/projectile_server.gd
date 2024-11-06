extends Node3D

var multimesh_pools: Dictionary[String,MultiMeshInstance3D] = {}
var active_projectiles: Dictionary[RID,ProjectileData]

const MAX_PROJECTILES_PER_POOL = 10000
	

func _physics_process(delta: float) -> void:
	for key: RID in active_projectiles.keys():
		active_projectiles[key].lived += delta
		var proj: ProjectileData = active_projectiles[key]
		
		if proj.lived >= proj.lifetime:
			destroy_projectile(proj.body)
			continue
		var current_transform: Transform3D = PhysicsServer3D.body_get_state(proj.body, PhysicsServer3D.BODY_STATE_TRANSFORM)
		var new_position: Vector3 = current_transform.origin + proj.velocity * delta
		current_transform.origin = new_position
		
		PhysicsServer3D.body_set_state(proj.body, PhysicsServer3D.BODY_STATE_TRANSFORM, current_transform)
		proj.multimesh.set_instance_transform(proj.instance_id, current_transform)
	

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
	var main: Node = get_tree().current_scene
	main.add_child(multimesh_instance)
	multimesh_pools[mesh_path] = multimesh_instance
	return multimesh_instance

func find_available_instance_id(multimesh: MultiMesh) -> int:
	for i in MAX_PROJECTILES_PER_POOL: #THIS MAY BE AWFUL
		if multimesh.get_instance_custom_data(i).a < 0.5:
			return i
	print("no projs :(")
	return -1

func spawn_projectile(
	mesh_resource: Mesh, start_transform: Transform3D, target_pos: Vector3,
	speed: float, damage: int, faction: int, lifetime: float
	) -> void:
	var ps:= PhysicsServer3D
	var mesh_path: String = mesh_resource.resource_path
	var multimesh_instance: MultiMeshInstance3D = get_or_create_multimesh_pool(mesh_path,mesh_resource)
	
	var body: RID = ps.body_create()
	ps.body_set_mode(body, ps.BODY_MODE_KINEMATIC)
	ps.body_set_state(body,ps.BODY_STATE_TRANSFORM,start_transform)
	ps.body_set_space(body, get_tree().root.world_3d.space)

	var shape: RID = ps.sphere_shape_create()
	ps.shape_set_data(shape,6)
	
	ps.body_add_shape(body,shape)
	#ps.body_set_collision_layer(body,0b1000)
	ps.body_set_collision_layer(body,0b100)
	ps.body_set_collision_mask(body, 0b100)


	
	var direction: Vector3 = (target_pos - start_transform.origin).normalized()
	var velocity: Vector3 = direction * speed
	
	var instance_id: int = find_available_instance_id(multimesh_instance.multimesh)
	if instance_id == -1:
		return
		
	var proj_data: ProjectileData = ProjectileData.new()
	proj_data.body = body
	proj_data.shape = shape
	proj_data.multimesh = multimesh_instance.multimesh
	proj_data.instance_id = instance_id
	proj_data.velocity = velocity
	proj_data.damage = damage
	proj_data.faction = faction
	proj_data.start_pos = start_transform.origin
	proj_data.lifetime = lifetime
	
	active_projectiles[body] = proj_data
	
	multimesh_instance.multimesh.set_instance_transform(instance_id,start_transform)
	multimesh_instance.multimesh.set_instance_custom_data(instance_id, Color(1,1,1,1))
	
func destroy_projectile(body: RID) -> void:
	var ps:= PhysicsServer3D
	var proj:ProjectileData = active_projectiles[body]
	
	ps.free_rid(proj.shape)
	ps.free_rid(proj.body)
	proj.multimesh.set_instance_custom_data(proj.instance_id,Color(1,1,1,0))
	
	active_projectiles.erase(body)
	

func get_proj_data_from_rid(body: RID) -> ProjectileData:
	return active_projectiles.get(body)