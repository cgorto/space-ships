class_name LaserGun extends Node3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var random_sound_player: RandomStreamPlayerComponent = $RandomStreamPlayerComponent
var projectile_speed: float = 100000

@export var laser_beam: PackedScene

@export var firing_points: Array[Marker3D]
var firing_point_counter: int = 0
var fire_rate: float = 0.5
var damage: float = 10
var laser_range: float = 1000

func _ready() -> void:
	attack_cooldown.wait_time = fire_rate

func shoot() -> void:
	if attack_cooldown.is_stopped():

		attack_cooldown.start()
		random_sound_player.play_random()
		

func shoot_towards(world_pos: Vector3) -> void:
	if attack_cooldown.is_stopped():
		var fire_from: Vector3 = firing_points[firing_point_counter].global_position if firing_points.size() > 0 else global_position
		var direction: Vector3 = global_position.direction_to(world_pos) * laser_range
		ray_cast_3d.target_position = to_local(world_pos)
		ray_cast_3d.force_raycast_update()
		var target_pos: Vector3 = direction
		if ray_cast_3d.is_colliding():
			
			var hurtbox: Hurtbox = ray_cast_3d.get_collider() as Hurtbox
			if hurtbox != null:
				hurtbox.handle_hit(damage,ray_cast_3d.get_collision_point(),3)
				target_pos = ray_cast_3d.get_collision_point()
		attack_cooldown.start()
		random_sound_player.play_random()
		var new_beam: LaserBeam = laser_beam.instantiate()
		new_beam.offset = fire_from
		new_beam.target_pos = target_pos
		add_child(new_beam)

		if firing_points.size() > 0:
			firing_point_counter = (firing_point_counter + 1) % firing_points.size()
