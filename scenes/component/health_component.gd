extends Node
class_name HealthComponent

signal died(thing_died: Node)
signal health_changed
signal health_decreased

 
@export var max_health: int = 10
var current_health: int


func _ready() -> void:
	current_health = max_health
	
func damage(damage_amount:int) -> void:
	current_health = clamp(current_health - damage_amount,0,max_health)
	health_changed.emit()
	if damage_amount > 0:
		health_decreased.emit()
	check_death.call_deferred()
	
func heal(heal_amount: int) -> void:
	damage(-heal_amount)
	
func check_death() -> void:
	if current_health == 0:
		died.emit(owner)
		owner.queue_free()
		#maybe just queuefree here, maybe do other stuff

func get_health_percent() -> float:
	if max_health <= 0:
		return 0

	return min((current_health as float) / (max_health as float),1)
	
func set_max_health(new_hp: int) -> void:
	var current_percent: float = get_health_percent()
	max_health = new_hp
	current_health = max_health * current_percent
