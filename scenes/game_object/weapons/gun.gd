class_name Gun extends Node3D

@onready var bullet_spawner: BulletSpawner = $BulletSpawner
@onready var attack_cooldown: Timer = $AttackCooldown

func _ready() -> void:
	attack_cooldown.wait_time = bullet_spawner.fire_rate

func shoot() -> void:
	if attack_cooldown.is_stopped():
		bullet_spawner.spawn_projectile()
		attack_cooldown.start()
