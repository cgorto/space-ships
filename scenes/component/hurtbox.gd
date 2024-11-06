class_name Hurtbox extends Area3D

signal hit

@export var health_component: HealthComponent



func _on_area_entered(area: Area3D) -> void:
	if not area is Hitbox:
		return
	if health_component == null:
		return
	
	var hitbox: Hitbox = (area as Hitbox)
	
	health_component.damage(hitbox.damage)
	hitbox.hit.emit(self)
	hit.emit()


func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	var proj_data: ProjectileData = ProjectileServer.get_proj_data_from_rid(body_rid)
	if proj_data == null:
		return
	if health_component == null:
		return
	print("yippee!")
	hit.emit()
	health_component.damage(proj_data.damage)
