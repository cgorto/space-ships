class_name Crosshair extends Sprite2D
@onready var hitmarker: Sprite2D = $Hitmarker

func _process(_delta: float) -> void:
	position = get_viewport().get_mouse_position()

func handle_hitmarker(_thing_hit: Hurtbox) -> void:
	hitmarker.show()
	await get_tree().create_timer(0.1).timeout
	hitmarker.hide()
