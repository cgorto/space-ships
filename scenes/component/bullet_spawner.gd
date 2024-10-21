class_name BulletSpawner extends Node3D

@export var fire_rate: float = 1
@export var spread: float = 0.0
@export var proj_speed: int = 500
@export var projectile_scene: PackedScene

func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		spawn_projectile()

func spawn_projectile() -> void:
		var spawn_transform: Transform3D = get_global_transform_interpolated()
		
		var main: Node = get_tree().current_scene
		
		var projectile: Projectile = (projectile_scene.instantiate() as Projectile)
		projectile.global_transform = spawn_transform
		main.add_child(projectile)
		projectile.velocity_component.velocity = - proj_speed * spawn_transform.basis.z