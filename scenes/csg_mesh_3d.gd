extends CSGMesh3D



func _on_hurtbox_hit() -> void:
	(material as StandardMaterial3D).albedo_color = Color.RED
