extends Node3D

# Camera
var camera: Camera3D

# Reticles
@onready var target_reticle: TextureRect = $TargetReticle
@onready var offscreen_reticle: TextureRect = $OffscreenReticle

# Attributes
var reticle_offset: Vector2 = Vector2(32, 32)
var border_offset: Vector2 = Vector2(32, 32)
var viewport_center: Vector2
var max_reticle_position: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	viewport_center = Vector2(get_viewport().size) / 2.0
	max_reticle_position = viewport_center - border_offset



func _process(_delta: float) -> void:
	if camera.is_position_in_frustum(global_position):
		target_reticle.show()
		offscreen_reticle.hide()
		var reticle_position: Vector2 = camera.unproject_position(global_position)
		target_reticle.set_global_position(reticle_position - reticle_offset)
	else:
		target_reticle.hide()
		offscreen_reticle.show()
		var local_to_camera: Vector3 = camera.to_local(global_position)
		var reticle_position: Vector2 = Vector2(local_to_camera.x, -local_to_camera.y)
		if reticle_position.abs().aspect() > max_reticle_position.aspect():
			reticle_position *= max_reticle_position.x / abs(reticle_position.x)
		else:
			reticle_position *= max_reticle_position.y / abs(reticle_position.y)
		offscreen_reticle.set_global_position(viewport_center + reticle_position - reticle_offset)
		var angle: float = Vector2.UP.angle_to(reticle_position)
		offscreen_reticle.rotation = angle


func targeted() -> void:
	target_reticle.modulate = Color("ff000828")
	offscreen_reticle.modulate = Color("ff00088c")


func untargeted()-> void:
	target_reticle.modulate = Color("ffffff28")
	offscreen_reticle.modulate = Color("ffffff8c")
