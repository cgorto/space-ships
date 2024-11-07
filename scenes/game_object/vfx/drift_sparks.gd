class_name DriftSparks extends Node3D

@onready var sparks1: GPUParticles3D = $GPUParticles3D

func start() -> void:
	sparks1.emitting = true
func stop() -> void:
	sparks1.emitting = false
