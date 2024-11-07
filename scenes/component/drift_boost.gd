class_name DriftBoost extends Node

signal drift_stage_changed(stage: int)
signal drift_ended(boost_power: float)
signal boost_started(power: float)
signal boost_ended

@export var pilot: Pilot
@export_group("Drift")
@export var drift_turn_mult: float = 1.5
@export var drift_speed_mult: float = 0.5
@export var min_drift_throttle: float = .1

@export_group("Boost")
@export var stage_1_charge_time: float = 1.0  # Blue spark timing
@export var stage_2_charge_time: float = 2.0  # Orange spark timing
@export var stage_3_charge_time: float = 3.0  # Purple spark timing
@export var stage_1_boost_power: float = 1.3
@export var stage_2_boost_power: float = 1.6
@export var stage_3_boost_power: float = 2.0 #charge time to power
@export var boost_duration: float = 2.0

enum DriftStage { NONE, STAGE_1, STAGE_2, STAGE_3 }
enum State { NORMAL, DRIFTING, BOOSTING }

var current_state: State = State.NORMAL
var current_drift_stage: DriftStage = DriftStage.NONE

var drift_timer: float = 0.0
var boost_timer: float = 0.0
var boost_power: float = 1.0

func _process(delta: float) -> void:
	match current_state:
		State.DRIFTING:
			process_drift(delta)
		State.BOOSTING:
			process_boost(delta)
			

func process_drift(delta: float) -> void:
	drift_timer += delta
	
	var new_stage: DriftStage = DriftStage.NONE
	if drift_timer >= stage_3_charge_time:
		new_stage = DriftStage.STAGE_3
	elif drift_timer >= stage_2_charge_time:
		new_stage = DriftStage.STAGE_2
	elif drift_timer >= stage_1_charge_time:
		new_stage = DriftStage.STAGE_1
	
	if new_stage != current_drift_stage:
		current_drift_stage = new_stage
		drift_stage_changed.emit(current_drift_stage)
		
func process_boost(delta: float) -> void:
	boost_timer -= delta
	if boost_timer <= 0:
		end_boost()

func start_boost(power: float) -> void:
	current_state = State.BOOSTING
	boost_power = power
	boost_timer = boost_duration
	boost_started.emit(power)
	
func end_boost() -> void:
	current_state = State.NORMAL
	boost_power = 1.0
	boost_timer = 0.0
	boost_ended.emit()

func start_drift() -> bool:
	if current_state == State.DRIFTING:
		return false
	if pilot.throttle < min_drift_throttle:
		return false
	
	current_state = State.DRIFTING
	drift_timer = 0.0
	current_drift_stage = DriftStage.NONE
	return true
	
func end_drift() -> void:
	if current_state != State.DRIFTING:
		return
	
	var boost_multiplier: float = get_boost_power_for_current_stage()
	drift_ended.emit(boost_multiplier)
	
	if boost_multiplier > 1.0:
		start_boost(boost_multiplier)
	else: 
		current_state = State.NORMAL
	drift_timer = 0.0
	current_drift_stage = DriftStage.NONE

func get_boost_power_for_current_stage() -> float:
	match current_drift_stage:
		DriftStage.STAGE_3:
			return stage_3_boost_power
		DriftStage.STAGE_2:
			return stage_2_boost_power
		DriftStage.STAGE_1:
			return stage_1_boost_power
		_:
			return 1.0

func get_turn_multiplier() -> float:
	return drift_turn_mult if current_state == State.DRIFTING else 1.0
	
func get_speed_multiplier() -> float:
	match current_state:
		State.DRIFTING:
			return drift_speed_mult
		State.BOOSTING:
			return boost_power
		_:
			return 1.0
