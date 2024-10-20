class_name ShipInput extends Node3D

@export var bank_limit: float = deg_to_rad(50)
@export var pitch_sensitivity: float = 2.5
@export var yaw_sensitivity: float = 2.5
@export var roll_sensivity: float = 1

@export_range(-1,1) var pitch: float
@export_range(-1,1) var yaw: float
@export_range(-1,1) var roll: float
@export_range(-1,1) var strafe: float
@export_range(0,1) var throttle: float


var pitch_pid: PID = PID.new(1.5, 1, 0.5)
var yaw_pid: PID = PID.new(1.5, 1, 0.5)
var roll_pid: PID = PID.new(2, 2, 1)

@export var throttle_speed: float = 0.5

@onready var debug_ray: RayCast3D = $RayCast3D
@onready var sprite: Sprite2D = $CanvasLayer/Sprite2D
@onready var label: Label = $CanvasLayer/Label
@onready var throt: ProgressBar = $CanvasLayer/ProgressBar
@onready var yaw_lab: Label = $CanvasLayer/VBoxContainer/Yaw
@onready var roll_lab: Label = $CanvasLayer/VBoxContainer/Roll
@onready var pitch_lab: Label = $CanvasLayer/VBoxContainer/Pitch

func _process(delta: float) -> void:
	strafe = Input.get_axis("move_left","move_right")
	
	auto_pilot(delta)
	update_throttle(delta)


func auto_pilot(delta:float) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var world_pos: Vector3 = camera.project_position(mouse_pos, 1000)
	
	sprite.position = mouse_pos
	label.text = "Mouse coord: " + str(get_mouse_pos())
	turn_towards_point(world_pos, delta)
	bank_ship_relative_to_up(mouse_pos,camera.global_basis.y, delta)
	
func bank_ship_relative_to_up(mouse_pos: Vector2, up: Vector3, delta:float) -> void:
	var bank_influence: float = (mouse_pos.x - (get_viewport().size.x * 0.5)) / (get_viewport().size.x * 0.5)
	bank_influence = clampf(bank_influence,-1,1)
	bank_influence *= throttle
	
	var bank_target: float = - bank_influence * bank_limit
	var bank_current: float = global_transform.basis.y.signed_angle_to(up, -global_transform.basis.z)
	var bank: float = roll_pid.update(bank_target, bank_current, delta)
	#bank_error = bank_error - bank_target
	bank = clampf(bank, -1,1)
	
	roll = bank
	roll_lab.text = "Roll: " + str(roll)


func turn_towards_point(to: Vector3, delta: float) -> void:
	# ============= v SHOULD HAVE PARITY v =======================
	var local_to: Vector3 = to_local(to).normalized()
	#var local_to: Vector3 = global_transform.inverse() * (to - global_position)
	debug_ray.target_position = local_to * 1000
	
	
	pitch = clampf(pitch_pid.update(0, -local_to.y, delta), -1, 1)
	yaw = clampf(yaw_pid.update(0, local_to.x, delta), -1,1)
	pitch_lab.text ="Pitch: " + str(pitch)
	yaw_lab.text = "Yaw: " + str(yaw)
	# ============= ^ SHOULD HAVE PARITY ^ =======================
	
func update_throttle(delta: float) -> void:
	var target: float = throttle
	if Input.is_action_pressed("move_forward"):
		target = 1
	elif Input.is_action_pressed("move_backward"):
		target = 0
	throttle = move_toward(throttle, target, throttle_speed * delta)
	throt.value = throttle

func get_mouse_pos() -> Vector2:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var half_screen_size: Vector2 = get_viewport().size * 0.5
	return (mouse_pos - half_screen_size) / half_screen_size
