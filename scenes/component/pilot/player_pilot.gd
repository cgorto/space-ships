class_name PlayerPilot extends Pilot

signal is_aimed(aimed: bool)

@onready var throt: ProgressBar = $CanvasLayer/ProgressBar
@onready var dash_bar: ProgressBar = $CanvasLayer/ProgressBar2
@onready var target_cast: RayCast3D = $RayCast3D
@onready var target_indicator: Sprite3D = $TargetIndicator
@onready var lead_crosshair: Sprite3D = $TargetIndicator/LeadCrosshair
@onready var target_cam: Node3D = $CanvasLayer/Control/Control/SubViewportContainer/SubViewport/TargetCam
@onready var target_cam_pivot: Node3D = $CanvasLayer/Control/Control/SubViewportContainer/SubViewport/TargetCam/Pivot
@onready var target_hp_bar: ProgressBar =$CanvasLayer/Control/Control/TargetHPBar
@onready var drift_boost: DriftBoost = $DriftBoost
@onready var speed: Label = $CanvasLayer/Control/Label3
@export var drift_sparks: DriftSparks
@onready var crosshair: Crosshair = $CanvasLayer/Crosshair
@onready var progress_bar_3: ProgressBar = $CanvasLayer/ProgressBar3


var target: RigidBody3D = null


@export var crosshair_radius: float = 20
@export var crosshair_hit: bool = false

func _ready() -> void:

	drift_boost.drift_ended.connect(_on_drift_ended)
	weapon.hit.connect(crosshair.handle_hitmarker)
	is_aimed.connect(crosshair.while_aimed)
func _process(delta: float) -> void:
	strafe = Input.get_axis("move_left","move_right")
	
	auto_pilot(delta)
	update_throttle(delta)
	update_drift()
	update_target_indicator()
	progress_bar_3.value = weapon.heat_meter



func auto_pilot(delta:float) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var world_pos: Vector3 = camera.project_position(mouse_pos, 1000)
	
	turn_towards_point(world_pos, delta)
	bank_ship_relative_to_up(mouse_pos,camera.global_basis.y, delta)
	if Input.is_action_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("target"):
		find_target(world_pos)

func update_throttle(delta: float) -> void:
	var throttle_target: float = throttle
	if Input.is_action_pressed("move_forward"):
		throttle_target = 1
	elif Input.is_action_pressed("move_backward"):
		throttle_target = -.2
	
	throttle = move_toward(throttle, throttle_target, throttle_speed * delta)
	if Input.is_action_just_pressed("cut_throttle"):
		throttle = 0
	throt.value = throttle
	speed.text = "Speed: %d" % own_ship.linear_velocity.length()
	throttle_changed.emit(throttle)

func find_target(mouse_direction: Vector3) -> void:
	target_cast.target_position = to_local(mouse_direction)
	target_cast.force_raycast_update()
	if target_cast.is_colliding():
		#if target != null:
			#(target.mesh as MeshInstance3D).set_layer_mask_value(2, true)
			#(target.mesh as MeshInstance3D).set_layer_mask_value(3, false)
		target = (target_cast.get_collider() as TargetArea).ship

		
func update_target_indicator() -> void:
	if target != null:
		#target_indicator.visible = not get_viewport().get_camera_3d().is_position_behind(global_transform.origin)
		target_hp_bar.value = target.hp.get_health_percent()
		target_indicator.global_position = target.global_position
		target_indicator.visible = true
		
		#var relative_pos: Vector3 = own_ship.global_position - target.global_position
		#var relative_vel: Vector3 = own_ship.linear_velocity - target.linear_velocity
		#var lead_time: float = Util.calculate_lead(relative_pos,relative_vel,-weapon.bullet_spawner.proj_speed)
		var lead_pos: Vector3 = Util.calculate_lead(own_ship,target,weapon.projectile_speed)
		#var world_pos: Vector3 = target.global_position + (target.linear_velocity * lead_time)
		lead_crosshair.global_position = lead_pos
		is_within_crosshair(get_viewport().get_mouse_position())
		
		target_cam.global_position = target.global_position
		var camera: Camera3D = get_viewport().get_camera_3d()
		target_cam_pivot.position = (camera.global_position - target_cam.global_position).normalized() * 20
		target_cam_pivot.look_at(target_cam.global_position,camera.global_basis.y)
	else:
		is_aimed.emit(false)
		target_hp_bar.value = 0
		target_indicator.visible = false

func shoot() -> void:
	var aim_point: Vector3 = get_aim_point()
	weapon.shoot_towards(aim_point)

func get_screen_position(world_pos: Vector3) -> Vector2:
	var camera: Camera3D = get_viewport().get_camera_3d()
	return camera.unproject_position(world_pos)
	
func is_within_crosshair(mouse_pos: Vector2) -> bool:
	var screen_pos: Vector2= get_screen_position(lead_crosshair.global_position)
	var is_within: bool = screen_pos.distance_to(mouse_pos) < crosshair_radius
	is_aimed.emit(is_within)
	return is_within
	
func get_aim_point() -> Vector3:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var aim_distance: float = 500
	crosshair_hit = false
	
	if target != null && camera.is_position_in_frustum(target.global_position):
		#var lead_screen_pos: Vector2 = get_screen_position(lead_crosshair.global_position)
		aim_distance = camera.global_position.distance_to(lead_crosshair.global_position)
		#if is_within_crosshair(lead_screen_pos, mouse_pos):
			#crosshair_hit = true
			#return lead_crosshair.global_position
		
			
	return camera.project_position(mouse_pos, aim_distance)


func update_drift() -> void:
	if Input.is_action_just_pressed("drift"):
		drift_boost.start_drift()
		drift_sparks.start()
	if Input.is_action_just_released("drift"):
		drift_boost.end_drift()
		
	speed_multiplier = drift_boost.get_speed_multiplier()
	turn_multiplier = drift_boost.get_turn_multiplier()


func _on_drift_ended(boost_mult:float) -> void:
	drift_sparks.stop(boost_mult)
