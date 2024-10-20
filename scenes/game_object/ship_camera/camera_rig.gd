class_name CameraRig extends Node3D

@export var ship: Node3D #Ship to follow
@export var smooth_speed: float = 10
@export var fancy_cam: bool

@export_category("Lookahead Values")
@export var horizontal_turn_angle: float = deg_to_rad(40)
@export var vertical_turn_up_angle: float = deg_to_rad(15)
@export var vertical_turn_down_angle: float = deg_to_rad(40)

@onready var camera: Node3D = $LookAheadRig/MainCamera
@onready var look_ahead_rig: Node3D = $LookAheadRig



func _physics_process(delta: float) -> void:
	move_camera(delta)



func move_camera(delta:float) -> void:
	if ship == null:
		return
	
	global_position = ship.global_position
	var target_rig_rotation: Quaternion = Util.qt_look_at(ship.global_transform.basis.z, global_transform.basis.y)
	#quaternion = Util.qt_damp(quaternion,target_rig_rotation, smooth_speed, delta)
	
	global_transform.basis = Basis(Util.qt_damp(global_transform.basis.get_rotation_quaternion(),target_rig_rotation,smooth_speed, delta))
	
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
	var vertical: float = vertical_turn_down_angle * mouse_screen_y if mouse_screen_y < 0.0 else vertical_turn_up_angle * mouse_screen_y
	
	var target_rotation: Quaternion = Quaternion.from_euler(Vector3(-vertical, horizontal , 0))
	look_ahead_rig.transform.basis = Basis(Util.qt_damp(look_ahead_rig.quaternion,target_rotation, smooth_speed, delta))

	var lookahead_pos: Vector3 = ship.global_position-(ship.global_transform.basis.z * 100)
	$LookAheadRig/MainCamera/Camera3D/RayCast3D.target_position = camera.to_local(lookahead_pos)
	#var camera_rotation: Quaternion = Util.qt_look_at(lookahead_pos - camera.global_position, look_ahead_rig.global_transform.basis.y)
	var camera_rotation: Quaternion = Util.qt_look_at(camera.to_local(lookahead_pos), look_ahead_rig.global_transform.basis.y)
	#double localizing it???
	
	
	camera.look_at(lookahead_pos, look_ahead_rig.global_transform.basis.y)
	#camera.global_transform.basis = Basis(camera_rotation)





#.look_at source:

#void Node3D::look_at(const Vector3 &p_target, const Vector3 &p_up, bool p_use_model_front) {
	#ERR_THREAD_GUARD;
	#ERR_FAIL_COND_MSG(!is_inside_tree(), "Node not inside tree. Use look_at_from_position() instead.");
	#Vector3 origin = get_global_transform().origin;
	#look_at_from_position(origin, p_target, p_up, p_use_model_front);
#}
#
#void Node3D::look_at_from_position(const Vector3 &p_pos, const Vector3 &p_target, const Vector3 &p_up, bool p_use_model_front) {
	#ERR_THREAD_GUARD;
	#ERR_FAIL_COND_MSG(p_pos.is_equal_approx(p_target), "Node origin and target are in the same position, look_at() failed.");
	#ERR_FAIL_COND_MSG(p_up.is_zero_approx(), "The up vector can't be zero, look_at() failed.");
	#ERR_FAIL_COND_MSG(p_up.cross(p_target - p_pos).is_zero_approx(), "Up vector and direction between node origin and target are aligned, look_at() failed.");
#
	#Vector3 forward = p_target - p_pos;
	#Basis lookat_basis = Basis::looking_at(forward, p_up, p_use_model_front);
	#Vector3 original_scale = get_scale();
	#set_global_transform(Transform3D(lookat_basis, p_pos));
	#set_scale(original_scale);
#}
