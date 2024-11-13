class_name Hurtbox extends Area3D

signal hit

@export var health_component: HealthComponent
@export var faction: int = 0
@export var on_hit_effect: PackedScene

func handle_hit(damage: int, hit_position: Vector3, attacker_faction: int) -> void:
	if health_component == null or attacker_faction == faction:
		return
	hit.emit()
	health_component.damage(damage)
	
	if on_hit_effect != null:
		var new_effect: Node3D = on_hit_effect.instantiate()
		add_child(new_effect)
		new_effect.position = global_position.direction_to(hit_position).normalized() * randf_range(3,6)


func _on_area_entered(area: Area3D) -> void:
	if not area is Hitbox:
		return
	if health_component == null:
		return
	
	var hitbox: Hitbox = (area as Hitbox)
	
	handle_hit(hitbox.damage, hitbox.global_position, 0)
	hitbox.hit.emit(self)


func _on_body_shape_entered(body_rid: RID, _body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	var proj_data: ProjectileData = ProjectileServer.get_proj_data_from_rid(body_rid)
	if proj_data == null:
		return
	if health_component == null:
		return
	if proj_data.ignored.has(get_rid()):
		return
	handle_hit(proj_data.damage,proj_data.position,proj_data.faction)
	ProjectileServer.destroy_projectile(body_rid)
