class_name Trail3D extends MeshInstance3D

var _points: Array[Vector3] = []
var _widths: Array = []
var _life_points: Array[float] = []

@export var _enabled: bool = true

@export var _from_width: float = 0.5
@export var _to_width: float = 0.0
@export_range(0.5, 1.5) var _scale_acceleration: float = 1

@export var _motion_delta: float = 0.1
@export var _life_span: float = 1.0

@export var _start_color: Color = Color(1.0,1.0,1.0,1.0)
@export var _end_color: Color = Color(1.0,1.0,1.0,1.0)

var _old_pos: Vector3

func _ready() -> void:
	_old_pos = get_global_transform_interpolated().origin
	mesh = ImmediateMesh.new()
	
func append_point() -> void:
	var curr_transform: Transform3D = get_global_transform_interpolated()
	_points.append(curr_transform.origin)
	var x_basis: Vector3 = curr_transform.basis.x
	_widths.append([
		x_basis * _from_width, 
		x_basis * _from_width - x_basis * _to_width
	])
	_life_points.append(0.0)

func remove_point(i: int) -> void:
	_points.remove_at(i)
	_widths.remove_at(i)
	_life_points.remove_at(i)
	

func _process(delta: float) -> void:
	if (_old_pos - get_global_transform_interpolated().origin).length() > _motion_delta and _enabled:
		append_point()
		_old_pos = get_global_transform_interpolated().origin
		
	var p: int = 0
	var max_points: int = _points.size()
	
	while p < max_points:
		_life_points[p] += delta
		if _life_points[p] > _life_span:
			remove_point(p)
			p -= 1
			if (p < 0): p = 0
		
		max_points = _points.size()
		p += 1
	(mesh as ImmediateMesh).clear_surfaces()
	
	if _points.size() < 2:
		return
	
	(mesh as ImmediateMesh).surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for i in range(_points.size()):
		var t: float = float(i) / (_points.size() - 1.0)
		var curr_color: Color = _start_color.lerp(_end_color, 1 - t)
		(mesh as ImmediateMesh).surface_set_color(curr_color)
		
		var curr_wdith: Vector3 = _widths[i][0] - pow(1 - t, _scale_acceleration) * _widths[i][1]
		
		var t0: float = i / _points.size()
		var t1: float = t
		
		(mesh as ImmediateMesh).surface_set_uv(Vector2(t0,0))
		(mesh as ImmediateMesh).surface_add_vertex(to_local(_points[i] + curr_wdith))
		(mesh as ImmediateMesh).surface_set_uv(Vector2(t1,1))
		(mesh as ImmediateMesh).surface_add_vertex(to_local(_points[i] - curr_wdith))
	(mesh as ImmediateMesh).surface_end()
