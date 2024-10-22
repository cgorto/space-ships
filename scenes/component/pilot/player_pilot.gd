class_name PlayerPilot extends Pilot

@onready var sprite: Sprite2D = $CanvasLayer/Sprite2D
@onready var label: Label = $CanvasLayer/Label
@onready var throt: ProgressBar = $CanvasLayer/ProgressBar


func _process(delta: float) -> void:
	strafe = Input.get_axis("move_left","move_right")
	
	auto_pilot(delta)
	update_throttle(delta)
	if Input.is_action_pressed("shoot"):
		weapon.shoot()


func auto_pilot(delta:float) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var world_pos: Vector3 = camera.project_position(mouse_pos, 1000)
	
	sprite.position = mouse_pos
	turn_towards_point(world_pos, delta)
	bank_ship_relative_to_up(mouse_pos,camera.global_basis.y, delta)

func update_throttle(delta: float) -> void:
	var target: float = throttle
	if Input.is_action_pressed("move_forward"):
		target = 1
	elif Input.is_action_pressed("move_backward"):
		target = -.2
	
	throttle = move_toward(throttle, target, throttle_speed * delta)
	throt.value = throttle
