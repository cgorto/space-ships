class_name Gun extends Node3D

@onready var bullet_spawner: BulletSpawner = $BulletSpawner
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var random_sound_player: RandomStreamPlayerComponent = $RandomStreamPlayerComponent

@export var firing_points: Array[Marker3D]
var firing_point_counter: int = 0

func _ready() -> void:
	attack_cooldown.wait_time = bullet_spawner.fire_rate

func shoot() -> void:
	if attack_cooldown.is_stopped():
		bullet_spawner.spawn_projectile()
		attack_cooldown.start()
		random_sound_player.play_random()
		

func shoot_towards(world_pos: Vector3) -> void:
	if attack_cooldown.is_stopped():
		var fire_from: Vector3 = firing_points[firing_point_counter].global_position if firing_points.size() > 0 else global_position
		var direction: Vector3 = (world_pos - fire_from).normalized()
		var to_qt: Quaternion = Util.qt_look_at(-direction,global_basis.y)
		var towards: Transform3D = Transform3D(Basis(to_qt),fire_from)
		bullet_spawner.spawn_projectile(towards)
		attack_cooldown.start()
		random_sound_player.play_random()
		firing_point_counter = (firing_point_counter + 1) % firing_points.size()
