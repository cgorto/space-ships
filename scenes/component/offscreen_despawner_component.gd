extends VisibleOnScreenNotifier3D

@onready var timer: Timer = $Timer

func _on_timer_timeout() -> void:
	owner.queue_free()


func _on_screen_exited() -> void:
	timer.start()
