extends Node3D
@onready var debris: GPUParticles3D = $Debris
@onready var smoke: GPUParticles3D = $Smoke
@onready var fire: GPUParticles3D = $Fire
@onready var random_stream_player_component: RandomStreamPlayerComponent = $RandomStreamPlayerComponent

func _ready() -> void:
	debris.emitting = true
	smoke.emitting = true
	fire.emitting = true
	random_stream_player_component.play_random()

func _on_smoke_finished() -> void:
	queue_free()
