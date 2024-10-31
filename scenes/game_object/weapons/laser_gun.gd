class_name LaserGun extends Node3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var random_sound_player: RandomStreamPlayerComponent = $RandomStreamPlayerComponent
@onready var laser: MeshInstance3D = $MeshInstance3D

@export var firing_points: Array[Marker3D]
var firing_point_counter: int = 0
var fire_rate: float = 0.5
var damage: float = 10

func _ready() -> void:
	attack_cooldown.wait_time = fire_rate

func shoot() -> void:
	if attack_cooldown.is_stopped():

		attack_cooldown.start()
		random_sound_player.play_random()
		

func shoot_towards(world_pos: Vector3) -> void:
	if attack_cooldown.is_stopped():
		var fire_from: Vector3 = firing_points[firing_point_counter].global_position if firing_points.size() > 0 else global_position
		var direction: Vector3 = (world_pos - fire_from)
		ray_cast_3d.target_position = direction
		ray_cast_3d.force_raycast_update()
		if ray_cast_3d.is_colliding():
			var hurtbox: Hurtbox = ray_cast_3d.get_collider() as Hurtbox
			if hurtbox != null:
				hurtbox.health_component.damage(10)
		attack_cooldown.start()
		random_sound_player.play_random()
		firing_point_counter = (firing_point_counter + 1) % firing_points.size()

func draw_laser(from: Vector3, to: Vector3) -> void:
	laser.global_position = from
	var box: BoxMesh = (laser.mesh as BoxMesh)
	box.size.z = (to-from).length()
