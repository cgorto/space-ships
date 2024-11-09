class_name MuzzleFlash extends Node3D

@onready var muzzle_flash: GPUParticles3D = $GPUParticles3D

func start(muzzle_pos: Vector3) -> void:
	global_position = muzzle_pos
	muzzle_flash.emitting = true
	await get_tree().create_timer(0.3).timeout
	muzzle_flash.emitting = false
