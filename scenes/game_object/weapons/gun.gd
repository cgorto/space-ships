class_name Gun extends Node3D

signal hit(thing_hit: Hurtbox)

@onready var attack_cooldown: Timer = $AttackCooldown
@onready var random_sound_player: RandomStreamPlayerComponent = $RandomStreamPlayerComponent
@onready var hit_sound_player: RandomStreamPlayerComponent = $RandomStreamPlayerComponent2

@export var proj_mesh: Mesh
@export var own_ship: Ship


@export var firing_points: Array[Marker3D]
@export_category("Stats")
@export var projectile_speed: float = 750
@export var projectile_damage: float = 10
@export var attack_speed: float = 0.3
@export var faction: int = 1
@export var lifetime: float = 10
@export var spread: float = 0
@export var shot_heat: float = 0.05
@export var cool_rate: float = 0.1


var firing_point_counter: int = 0
var heat_meter: float = 0.0



func _ready() -> void:
	attack_cooldown.wait_time = attack_speed
	random_sound_player.max_polyphony = firing_points.size()
	
func _process(delta: float) -> void:
	heat_meter = move_toward(heat_meter,0.0,cool_rate * delta)


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
	if attack_cooldown.is_stopped() and (heat_meter + shot_heat) < 1.0:
		var fire_from: Vector3 = firing_points[firing_point_counter].global_position if firing_points.size() > 0 else global_position
		var direction: Vector3 = (world_pos - fire_from).normalized()
		var to_qt: Quaternion = Util.qt_look_at(-direction,global_basis.y)
		var towards: Transform3D = Transform3D(Basis(to_qt),fire_from)
		var new_proj: ProjectileData = ProjectileServer.spawn_projectile(
			proj_mesh,
			towards,
			world_pos,
			projectile_speed,
			projectile_damage,
			faction,
			lifetime,
			[own_ship,own_ship.hurtbox]
		)
		new_proj.hit.connect(on_projectile_hit)
		attack_cooldown.start()
		random_sound_player.play_random()
		heat_meter += shot_heat
		if not firing_points.is_empty():
			firing_point_counter = (firing_point_counter + 1) % firing_points.size()

func on_projectile_hit(thing_hit: Hurtbox) -> void:
	hit.emit(thing_hit)
	hit_sound_player.play_random()
