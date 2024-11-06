class_name Hurtbox extends Area3D

signal hit

@export var health_component: HealthComponent
@export var faction: int = 0
@export var on_hit_effect: PackedScene


func _on_area_entered(area: Area3D) -> void:
	if not area is Hitbox:
		return
	if health_component == null:
		return
	
	var hitbox: Hitbox = (area as Hitbox)
	
	health_component.damage(hitbox.damage)
	hitbox.hit.emit(self)
	hit.emit()


func _on_body_shape_entered(body_rid: RID, _body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	var proj_data: ProjectileData = ProjectileServer.get_proj_data_from_rid(body_rid)
	if proj_data == null:
		return
	if health_component == null:
		return
	if not proj_data.ignored.has(get_rid()):
		if proj_data.faction != faction:
			hit.emit()
			health_component.damage((proj_data.damage as int))
			if on_hit_effect != null:
				var new_effect: Node3D = on_hit_effect.instantiate()
				add_child(new_effect)
				new_effect.global_position = PhysicsServer3D.body_get_state(proj_data.body, PhysicsServer3D.BODY_STATE_TRANSFORM).origin
		ProjectileServer.destroy_projectile(body_rid)
