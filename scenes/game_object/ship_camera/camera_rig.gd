class_name CameraRig extends Node3D

@export var ship: Node3D #Ship to follow
@export var smooth_speed: float = 5
@export var fancy_cam: bool

@export_category("Lookahead Values")
@export var horizontal_turn_angle: float = deg_to_rad(15)
@export var vertical_turn_up_angle: float = deg_to_rad(5)
@export var vertical_turn_down_angle: float = deg_to_rad(15)

@onready var camera: Node3D = $LookAheadRig/MainCamera
@onready var look_ahead_rig: Node3D = $LookAheadRig



func _physics_process(delta: float) -> void:
	move_camera(delta)
	if Input.is_action_just_pressed("ui_focus_next"):
		fancy_cam = not fancy_cam


func move_camera(delta:float) -> void:
	if ship == null:
		return
	
	global_position = ship.global_position
	var target_rig_rotation: Quaternion = Util.qt_look_at(ship.global_transform.basis.z, global_transform.basis.y)
	#quaternion = Util.qt_damp(quaternion,target_rig_rotation, smooth_speed, delta)
	global_transform.basis = Basis(global_transform.basis.get_rotation_quaternion().slerp(target_rig_rotation, smooth_speed * delta))
	
	if fancy_cam:
		look_ahead(delta)


func look_ahead(delta:float) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var screen_size: Vector2 = get_viewport().size
	
	var mouse_screen_x: float = (mouse_pos.x - (screen_size.x * 0.5)) / (screen_size.x * 0.5)
	var mouse_screen_y: float = -(mouse_pos.y - (screen_size.y * 0.5)) / (screen_size.y * 0.5)
	mouse_screen_x = clamp(mouse_screen_x, -1.0, 1.0)
	mouse_screen_y = clamp(mouse_screen_y, -1.0, 1.0)

	var horizontal: float = horizontal_turn_angle * mouse_screen_x
	var vertical: float = vertical_turn_up_angle * mouse_screen_y if mouse_screen_y < 0.0 else vertical_turn_down_angle * mouse_screen_y
	
	var target_rotation: Quaternion = Quaternion.from_euler(Vector3(-vertical, - horizontal , 0))
	look_ahead_rig.quaternion = Util.qt_damp(-look_ahead_rig.quaternion,target_rotation, smooth_speed, delta)

	var lookahead_pos: Vector3 = ship.global_position-(ship.global_transform.basis.z * 100)
	$LookAheadRig/MainCamera/Camera3D/RayCast3D.target_position = camera.to_local(lookahead_pos)
	#var camera_rotation: Quaternion = Util.qt_look_at(lookahead_pos - camera.global_position, look_ahead_rig.global_transform.basis.y)
	var camera_rotation: Quaternion = Util.qt_look_at(camera.to_local(lookahead_pos), look_ahead_rig.global_transform.basis.y)

	camera.look_at(lookahead_pos, look_ahead_rig.global_transform.basis.y)
	#camera.global_transform.basis = Basis(camera_rotation)
