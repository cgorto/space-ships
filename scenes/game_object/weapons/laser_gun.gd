class_name LaserGun extends Node3D

signal hit()

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var random_sound_player: RandomStreamPlayerComponent = $RandomStreamPlayerComponent
@onready var hit_sound_player: RandomStreamPlayerComponent = $RandomStreamPlayerComponent2
var projectile_speed: float = 1000000

@export var laser_beam: PackedScene

@export var firing_points: Array[Marker3D]
var firing_point_counter: int = 0
@export var attack_speed: float = 0.3
@export var damage: float = 10
@export var laser_range: float = 1000
@export var shot_heat: float = 0.05
@export var cool_rate: float = 0.1

var heat_meter: float = 0.0

func _ready() -> void:
	attack_cooldown.wait_time = attack_speed
	random_sound_player.max_polyphony = firing_points.size()
	
func _process(delta: float) -> void:
	heat_meter = move_toward(heat_meter,0.0,cool_rate * delta)

func shoot() -> void:
	if attack_cooldown.is_stopped():

		attack_cooldown.start()
		random_sound_player.play_random()
		

func shoot_towards(world_pos: Vector3) -> void:
	if attack_cooldown.is_stopped() and (heat_meter + shot_heat) < 1.0:
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
				hit.emit(hurtbox)
				hit_sound_player.play_random()
		attack_cooldown.start()
		random_sound_player.play_random()
		heat_meter += shot_heat
		var new_beam: LaserBeam = laser_beam.instantiate()
		new_beam.offset = fire_from
		new_beam.target_pos = world_pos
		add_child(new_beam)

		if firing_points.size() > 0:
			firing_point_counter = (firing_point_counter + 1) % firing_points.size()
