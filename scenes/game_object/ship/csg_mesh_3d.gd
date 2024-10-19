extends CSGMesh3D

var counter: float = 0

func _physics_process(delta: float) -> void:
	counter += delta
	
	if counter > 1:
		print(global_position)
		counter = 0
