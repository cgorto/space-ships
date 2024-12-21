class_name Crosshair extends Node2D
@onready var hitmarker: Sprite2D = $Hitmarker
@onready var crosshair: Sprite2D = $CrosshairSprite
var is_aimed: bool = false
@export var rotate_speed: float = 8

func _process(_delta: float) -> void:
	position = get_viewport().get_mouse_position()
	if is_aimed:
		crosshair.self_modulate = Color.RED
		crosshair.rotation = Util.move_angle(crosshair.rotation, crosshair.rotation + PI / 2, rotate_speed,_delta)
	else:
		crosshair.self_modulate = Color.WHITE
		crosshair.rotation = 0
		

func handle_hitmarker(_thing_hit: Hurtbox) -> void:
	hitmarker.show()
	await get_tree().create_timer(0.1).timeout
	hitmarker.hide()

func while_aimed(_is_aimed: bool) -> void:
	is_aimed = _is_aimed
