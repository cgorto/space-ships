extends Label

func _process(_delta: float) -> void:
	text = "Active Projectiles: %d" % ProjectileServer.active_projectiles.size()
