extends Node3D

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

func _ready() -> void:
	animated_sprite_3d.animation_finished.connect(animation_finished)
	animated_sprite_3d.play("default")
	
func animation_finished() -> void:
	queue_free()
