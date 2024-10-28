class_name PlayerPilot extends Pilot

@onready var throt: ProgressBar = $CanvasLayer/ProgressBar
@onready var dash_bar: ProgressBar = $CanvasLayer/ProgressBar2
@onready var target_cast: RayCast3D = $RayCast3D
@onready var target_indicator: Sprite3D = $TargetIndicator
@onready var lead_crosshair: Sprite3D = $TargetIndicator/LeadCrosshair
@onready var target_cam: Node3D = $CanvasLayer/Control/Control/SubViewportContainer/SubViewport/TargetCam
@onready var target_cam_pivot: Node3D = $CanvasLayer/Control/Control/SubViewportContainer/SubViewport/TargetCam/Pivot
@onready var target_hp_bar: ProgressBar =$CanvasLayer/Control/Control/TargetHPBar
var target: Node3D = null
var dash_meter: float = 1
var dash_rate: float = 0.5
var dash_speed: float = 2
enum STATE {BASE,DASHING,DRIFT}
var current_state: STATE = STATE.BASE

func _process(delta: float) -> void:
	strafe = Input.get_axis("move_left","move_right")
	
	auto_pilot(delta)
	update_throttle(delta)
	dash(delta)
	fast_turn(delta)
	update_target_indicator()
	if current_state == STATE.BASE:
		dash_meter = move_toward(dash_meter,1,0.5 * dash_rate * delta)
	dash_bar.value = dash_meter


func auto_pilot(delta:float) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var world_pos: Vector3 = camera.project_position(mouse_pos, 1000)
	
	turn_towards_point(world_pos, delta)
	bank_ship_relative_to_up(mouse_pos,camera.global_basis.y, delta)
	if Input.is_action_pressed("shoot"):
		shoot(mouse_pos)
	if Input.is_action_just_pressed("target"):
		find_target(world_pos)

func update_throttle(delta: float) -> void:
	var throttle_target: float = throttle
	if Input.is_action_pressed("move_forward"):
		throttle_target = 1
	elif Input.is_action_pressed("move_backward"):
		throttle_target = -.2
	
	throttle = move_toward(throttle, throttle_target, throttle_speed * delta)
	throt.value = throttle

func find_target(mouse_direction: Vector3) -> void:
	target_cast.target_position = to_local(mouse_direction)
	target_cast.force_raycast_update()
	if target_cast.is_colliding():
		if target != null:
			(target.mesh as MeshInstance3D).set_layer_mask_value(2, true)
			(target.mesh as MeshInstance3D).set_layer_mask_value(3, false)
		target = (target_cast.get_collider() as TargetArea).ship
		(target.mesh as MeshInstance3D).set_layer_mask_value(3, true)
		
func update_target_indicator() -> void:
	if target != null:
		#target_indicator.visible = not get_viewport().get_camera_3d().is_position_behind(global_transform.origin)
		target_hp_bar.value = target.hp.get_health_percent()
		target_indicator.global_position = target.global_position
		target_indicator.visible = true
		lead_crosshair.global_position = Util.calculate_lead(own_ship,target,-weapon.bullet_spawner.proj_speed)
		
		
		
		target_cam.global_position = target.global_position
		var camera: Camera3D = get_viewport().get_camera_3d()
		target_cam_pivot.position = (camera.global_position - target_cam.global_position).normalized() * 20
		target_cam_pivot.look_at(target_cam.global_position,camera.global_basis.y)
		
		
		
	else:
		target_hp_bar.value = 0
		target_indicator.visible = false
		
func dash(delta: float) -> void:
	if not Input.is_action_pressed("dash") or current_state == STATE.DRIFT or dash_meter == 0:
		if not current_state == STATE.DRIFT:
			current_state = STATE.BASE
		if throttle > 1.0:
			throttle = move_toward(throttle,1.0,delta * throttle_speed)
		return
	current_state = STATE.DASHING
	throttle = move_toward(throttle,dash_speed,throttle_speed * delta)
	dash_meter = move_toward(dash_meter,0,dash_rate * delta)
	
func fast_turn(delta: float) -> void:
	if not Input.is_action_pressed("drift") or current_state == STATE.DASHING or dash_meter == 0:
		if not current_state == STATE.DASHING:
			current_state = STATE.BASE
		if own_ship.ship_physics.angular_force.length() > Vector3(deg_to_rad(100),deg_to_rad(100),deg_to_rad(100)).length():
			own_ship.ship_physics.angular_force = own_ship.ship_physics.angular_force.lerp(Vector3(deg_to_rad(100),deg_to_rad(100),deg_to_rad(100)),dash_speed * delta)
		return

	current_state = STATE.DRIFT
	own_ship.ship_physics.angular_force = own_ship.ship_physics.angular_force.lerp(Vector3(deg_to_rad(100),deg_to_rad(100),deg_to_rad(100)) * dash_speed,dash_rate * delta)
	dash_meter = move_toward(dash_meter,0,dash_rate * delta)

func shoot(mouse_pos: Vector2) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var aim_distance: int = 1000
	if target != null:
		aim_distance = camera.global_position.distance_to(target.global_position)
	var world_pos: Vector3 = camera.project_position(mouse_pos, aim_distance)
	weapon.shoot_towards(world_pos)
