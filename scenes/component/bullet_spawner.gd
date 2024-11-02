class_name BulletSpawner extends Node3D

@export var fire_rate: float = 0.1
@export var spread: float = 0.0
@export var proj_speed: int = 1000
@export var projectile_scene: PackedScene


func spawn_projectile(towards:Transform3D = global_transform) -> void:
		var main: Node = get_tree().current_scene
		
		var projectile: Projectile = (projectile_scene.instantiate() as Projectile)
		projectile.global_transform = towards
		main.add_child(projectile)
		projectile.velocity_component.velocity = - proj_speed * towards.basis.z
