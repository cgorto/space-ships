@tool
class_name Trail
extends MeshInstance3D

signal point_added(point: Vector3)
signal trail_cleared

@export var is_emitting: bool = false:
	set(value):
		set_emitting(value)
		is_emitting = value

@export_group("Trail Properties")
@export var lifetime: float = 0.5
@export var resolution: float = 0.1  # Distance between vertices
@export var max_points: int = 100
@export var base_width: float = 0.2
@export var target_path: NodePath
@export var update_frequency: float = 60.0  # How many times per second to update the mesh

@export_group("Trail Curves")
@export var transparency_curve: Curve:
	set(value):
		transparency_curve = value
		if transparency_curve == null:
			transparency_curve = create_default_curve()
@export var width_curve: Curve:
	set(value):
		width_curve = value
		if width_curve == null:
			width_curve = create_default_curve()

@export_group("Material")
@export var trail_material: Material:
	set(value):
		trail_material = value
		if _mesh != null:
			material_override = trail_material if trail_material != null else _default_material

var _points: Array[Vector3] = []
var _points_creation_time: Array[float] = []
var _last_point: Vector3
var _clock: float = 0.0
var _mesh: ImmediateMesh
var _default_material: StandardMaterial3D
var _target: Node3D
var _update_timer: float
var _should_update_mesh: bool = false
var _camera_position: Vector3
var _cached_right_vectors: Array[Vector3] = []
var _last_camera_pos: Vector3
var _update_offset: float # Random offset for update timing

func _ready() -> void:
	if not transparency_curve:
		transparency_curve = create_default_curve()
	if not width_curve:
		width_curve = create_default_curve()
	
	if not _target:
		_target = get_node_or_null(target_path)
		if not _target:
			_target = get_parent() as Node3D
	
	if Engine.is_editor_hint():
		set_process(false)
		return

	# Initialize with random offset between 0 and 1/update_frequency
	_update_offset = randf() * (1.0 / update_frequency)
	_update_timer = _update_offset
	
	setup_mesh()
	set_as_top_level(true)
	clear_trail()
	position = Vector3.ZERO
	_last_point = to_local(_target.global_position)

func create_default_curve() -> Curve:
	var curve := Curve.new()
	curve.add_point(Vector2(0, 1), 0, 0, 1)
	curve.add_point(Vector2(1, 0), 0, 0, 1)
	return curve

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _target:
		warnings.append("Missing Target node: assign a Node that extends Node3D in the Target Path or make the Trail a child of a parent that extends Node3D")
	return warnings

func _process(delta: float) -> void:
	_clock += delta
	_update_timer += delta
	
	var camera := get_viewport().get_camera_3d()
	if camera:
		_camera_position = camera.global_position
		# Only force mesh update if camera moved significantly
		if _camera_position.distance_to(_last_camera_pos) > 1.0:
			_should_update_mesh = true
			_last_camera_pos = _camera_position

	remove_older_points()

	if not is_emitting:
		return
	
	var desired_point: Vector3 = to_local(_target.global_position)
	var distance: float = _last_point.distance_to(desired_point)
	
	if distance > resolution:
		add_timed_point(desired_point, _clock)
		_should_update_mesh = true
	
	# Update mesh at specified frequency with jitter
	var update_interval := 1.0 / update_frequency
	if _update_timer >= update_interval and _should_update_mesh:
		update_mesh()
		_update_timer = 0.0
		# Add small random variation to next update time (-10% to +10% of interval)
		_update_timer -= update_interval * (randf() * 0.2 - 0.1)
		_should_update_mesh = false

func setup_mesh() -> void:
	_mesh = ImmediateMesh.new()
	mesh = _mesh
	
	_default_material = StandardMaterial3D.new()
	_default_material.vertex_color_use_as_albedo = true
	_default_material.vertex_color_is_srgb = true
	_default_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_default_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_default_material.emission_enabled = true
	_default_material.emission_energy_multiplier = 1.0
	
	material_override = trail_material if trail_material != null else _default_material

func add_timed_point(point: Vector3, time: float) -> void:
	_points.append(point)
	_points_creation_time.append(time)
	_cached_right_vectors.append(Vector3.ZERO) # Placeholder
	_last_point = point
	point_added.emit(point)
	
	if _points.size() > max_points:
		remove_first_point()

func remove_first_point() -> void:
	if _points.size() > 1:
		_points.pop_front()
		_points_creation_time.pop_front()
		_cached_right_vectors.pop_front()

func remove_older_points() -> void:
	var removed := false
	for i in range(_points_creation_time.size() - 1, -1, -1):
		var delta: float = _clock - _points_creation_time[i]
		if delta > lifetime:
			_points.remove_at(i)
			_points_creation_time.remove_at(i)
			_cached_right_vectors.remove_at(i)
			removed = true
		else:
			break
	
	if removed:
		_should_update_mesh = true

func update_mesh() -> void:
	_mesh.clear_surfaces()
	
	var point_count := _points.size()
	if point_count < 2:
		return
	
	_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	# Precalculate directions for all points
	var directions := _calculate_directions(point_count)
	
	# Update right vectors only if needed
	if _should_update_mesh:
		_update_right_vectors(directions)
	
	for i in range(point_count):
		var current_point := _points[i]
		var right := _cached_right_vectors[i]
		
		# Invert the progress so it goes from newest (0) to oldest (1)
		var trail_progress := 1.0 - (float(i) / float(point_count - 1))
		
		# Get alpha and width from curves
		var alpha := transparency_curve.sample(trail_progress)
		var width_multiplier := width_curve.sample(trail_progress)
		var current_width := base_width * width_multiplier
		
		var vertex_color := Color(1, 1, 1, alpha)
		
		# Add vertices for both sides of the trail
		_mesh.surface_set_color(vertex_color)
		_mesh.surface_add_vertex(current_point + right * current_width * 0.5)
		_mesh.surface_set_color(vertex_color)
		_mesh.surface_add_vertex(current_point - right * current_width * 0.5)
	
	_mesh.surface_end()

func _calculate_directions(point_count: int) -> Array[Vector3]:
	var directions: Array[Vector3] = []
	directions.resize(point_count)
	
	for i in range(point_count):
		if i == 0:
			directions[i] = (_points[i + 1] - _points[i]).normalized()
		elif i == point_count - 1:
			directions[i] = (_points[i] - _points[i - 1]).normalized()
		else:
			directions[i] = (_points[i + 1] - _points[i - 1]).normalized()
	
	return directions

func _update_right_vectors(directions: Array[Vector3]) -> void:
	var point_count := _points.size()
	_cached_right_vectors.resize(point_count)
	
	for i in range(point_count):
		var to_camera := (_camera_position - global_position - _points[i]).normalized()
		_cached_right_vectors[i] = directions[i].cross(to_camera).normalized()

func clear_trail() -> void:
	_points.clear()
	_points_creation_time.clear()
	_cached_right_vectors.clear()
	_mesh.clear_surfaces()
	trail_cleared.emit()

func set_emitting(emitting: bool) -> void:
	if Engine.is_editor_hint():
		return
	
	if not is_inside_tree():
		await ready
	
	if emitting:
		clear_trail()
		_last_point = to_local(_target.global_position)
