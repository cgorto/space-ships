class_name Gun extends Node3D

@export_category("Stats")
@export var projectile_speed: float = 750
@export var projectile_damage: float = 10
@export var attack_speed: float = 0.3
@export var faction: int = 1
@export var lifetime: float = 10

@onready var attack_cooldown: Timer = $AttackCooldown
@onready var random_sound_player: RandomStreamPlayerComponent = $RandomStreamPlayerComponent
@export var proj_mesh: Mesh
@export var own_ship: Ship

@export var firing_points: Array[Marker3D]
var firing_point_counter: int = 0




func _ready() -> void:
	attack_cooldown.wait_time = attack_speed

func shoot() -> void:
	if attack_cooldown.is_stopped():
		var target_pos: Vector3 = global_position - global_transform.basis.z * 100
		ProjectileServer.spawn_projectile(
			proj_mesh,
			global_transform,
			target_pos,
			projectile_speed,
			projectile_damage,
			faction,
			lifetime,
			[own_ship,own_ship.hurtbox]
		)
		#bullet_spawner.spawn_projectile()
		attack_cooldown.start()
		#random_sound_player.play_random()
		

func shoot_towards(world_pos: Vector3) -> void:
	if attack_cooldown.is_stopped():
		var fire_from: Vector3 = firing_points[firing_point_counter].global_position if firing_points.size() > 0 else global_position
		var direction: Vector3 = (world_pos - fire_from).normalized()
		var to_qt: Quaternion = Util.qt_look_at(-direction,global_basis.y)
		var towards: Transform3D = Transform3D(Basis(to_qt),fire_from)
		ProjectileServer.spawn_projectile(
			proj_mesh,
			towards,
			world_pos,
			projectile_speed,
			projectile_damage,
			faction,
			lifetime
		)
		attack_cooldown.start()
		random_sound_player.play_random()
		firing_point_counter = (firing_point_counter + 1) % firing_points.size()
