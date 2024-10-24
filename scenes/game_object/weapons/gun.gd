class_name Gun extends Node3D

@onready var bullet_spawner: BulletSpawner = $BulletSpawner
@onready var attack_cooldown: Timer = $AttackCooldown

func _ready() -> void:
	attack_cooldown.wait_time = bullet_spawner.fire_rate

func shoot() -> void:
	if attack_cooldown.is_stopped():
		bullet_spawner.spawn_projectile()
		attack_cooldown.start()

func shoot_towards(world_pos: Vector3) -> void:
	if attack_cooldown.is_stopped():
		var direction: Vector3 = (world_pos - global_position).normalized()
		var to_qt: Quaternion = Util.qt_look_at(-direction,global_basis.y)
		var towards: Transform3D = Transform3D(Basis(to_qt),global_position)
		bullet_spawner.spawn_projectile(towards)
		attack_cooldown.start()
