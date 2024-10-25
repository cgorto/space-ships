class_name Projectile extends Node3D

@onready var velocity_component: VelocityComponent = $VelocityComponent

func _physics_process(delta: float) -> void:
	velocity_component.move(self,delta)


func _on_hitbox_hit(_thing_hit: Node3D) -> void:
	queue_free()


func _on_timer_timeout() -> void:
	queue_free()
