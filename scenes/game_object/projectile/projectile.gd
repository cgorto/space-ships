class_name Projectile extends Node3D

@onready var velocity_component: VelocityComponent = $VelocityComponent

func _physics_process(delta: float) -> void:
	velocity_component.move(self)


func _on_hitbox_hit(thing_hit: Node3D) -> void:
	queue_free()
