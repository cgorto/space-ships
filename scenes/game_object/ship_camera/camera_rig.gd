class_name CameraRig extends Node3D

@export var ship: Node3D #Ship to follow
@export var smooth_speed: float = 10
@export var fancy_cam: bool

@export_category("Lookahead Values")
@export var horizontal_turn_angle: float = deg_to_rad(-20)
@export var vertical_turn_up_angle: float = deg_to_rad(30)
@export var vertical_turn_down_angle: float = deg_to_rad(20)

@onready var camera: Node3D = $LookAheadRig/MainCamera/Camera3D
@onready var look_ahead_rig: Node3D = $LookAheadRig

var counter:float = 0

func _physics_process(delta: float) -> void:
	move_camera(delta)


func move_camera(delta:float) -> void:
	if ship == null:
		return
	
	position = ship.position
	#This basis is not orthogonal.
	
	var target_rig_rotation: Basis = Basis.looking_at(-ship.transform.basis.z, transform.basis.y)
	#camera.transform.basis = camera.transform.basis.slerp(target_rig_rotation, smooth_speed * delta).orthonormalized()
	transform.basis = transform.basis.slerp(target_rig_rotation, smooth_speed * delta).orthonormalized()
	if fancy_cam:
		look_ahead(delta)

func look_ahead(delta:float) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var screen_size: Vector2 = get_viewport().size
	
	var mouse_screen: Vector2 = (mouse_pos - (screen_size * 0.5)) / (screen_size * 0.5)
	mouse_screen = mouse_screen.clampf(-1,1)
	var horizontal: float = horizontal_turn_angle * mouse_screen.x
	var vertical: float = vertical_turn_down_angle * mouse_screen.y if mouse_screen.y < 0.0 else vertical_turn_up_angle * mouse_screen.y

	#var target_rotation: Basis = Basis.from_euler(Vector3(vertical,horizontal,0),0)
	#look_ahead_rig.basis = look_ahead_rig.basis.slerp(target_rotation, smooth_speed * delta)

	look_ahead_rig.rotate(Vector3.BACK, vertical * delta)
	look_ahead_rig.rotate(Vector3.RIGHT, horizontal * delta)
	var up: Vector3 = global_transform.basis.y

	var lookahead_pos: Vector3 = ship.global_position-(ship.global_transform.basis.z * 100)
	$LookAheadRig/MainCamera/Camera3D/RayCast3D.target_position = camera.to_local(lookahead_pos)
	#counter += delta
	#if counter > .5:
		#look_ahead_rig.basis = look_ahead_rig.basis.orthonormalized()
		#counter=0.0

	#camera.look_at(lookahead_pos, camera.basis.y)
	camera.look_at(lookahead_pos, look_ahead_rig.basis.y)
	#camera.basis = camera.basis.looking_at(lookahead_pos, global_basis.y)
