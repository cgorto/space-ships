class_name DriftSparks extends Node3D

@onready var sparks1: GPUParticles3D = $GPUParticles3D
@onready var sparks2: GPUParticles3D = $GPUParticles3D2
@onready var sparks3: GPUParticles3D = $GPUParticles3D3
@onready var sparks0: GPUParticles3D = $GPUParticles3D4
@export var drift_boost: DriftBoost
func _ready() -> void:
	if drift_boost == null:
		return
	drift_boost.drift_stage_changed.connect(_on_drift_stage_changed)

func start() -> void:
	sparks0.emitting = true
func stop() -> void:
	sparks0.emitting = false
	sparks1.emitting = false
	sparks2.emitting = false
	sparks3.emitting = false

func _on_drift_stage_changed(stage: int) -> void:
	match stage:
		1:
			sparks0.emitting = false
			sparks1.emitting = true
		2:
			sparks2.emitting = true
			sparks1.emitting = false
		3:
			sparks3.emitting = true
			sparks2.emitting = false
		_:
			sparks0.emitting = false
			sparks1.emitting = false
			sparks2.emitting = false
			sparks3.emitting = false
