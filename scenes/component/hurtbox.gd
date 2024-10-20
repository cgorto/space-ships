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
