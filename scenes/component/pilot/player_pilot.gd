class_name PlayerPilot extends Pilot

@onready var throt: ProgressBar = $CanvasLayer/ProgressBar
@onready var target_cast: RayCast3D = $RayCast3D
@onready var target_indicator: Sprite3D = $TargetIndicator
@onready var lead_crosshair: Sprite3D = $TargetIndicator/LeadCrosshair
var target: Node3D = null


func _process(delta: float) -> void:
	strafe = Input.get_axis("move_left","move_right")
	
	auto_pilot(delta)
	update_throttle(delta)
	update_target_indicator()


func auto_pilot(delta:float) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var world_pos: Vector3 = camera.project_position(mouse_pos, 1000)
	
	turn_towards_point(world_pos, delta)
	bank_ship_relative_to_up(mouse_pos,camera.global_basis.y, delta)
	if Input.is_action_pressed("shoot"):
		weapon.shoot_towards(world_pos)
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
		target = (target_cast.get_collider() as TargetArea).ship
		
func update_target_indicator() -> void:
	if target != null:
		#target_indicator.visible = not get_viewport().get_camera_3d().is_position_behind(global_transform.origin)
		target_indicator.global_position = target.global_position
		target_indicator.visible = true
		lead_crosshair.global_position = Util.calculate_lead(own_ship,target,-weapon.bullet_spawner.proj_speed)
	else:
		target_indicator.visible = false
