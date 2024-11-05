extends Label

func _process(delta: float) -> void:
	text = "Active Projectiles: %d" % ProjectileServer.active_projectiles.size()
