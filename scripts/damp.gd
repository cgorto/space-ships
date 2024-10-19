extends Object
class_name Damp

# Smoothly rotates from one Quat to another, frame-rate independent.
static func rotate(from: Quaternion, to: Quaternion, speed: float, dt: float) -> Quaternion:
	return from.slerp(to, 1.0 - exp(-speed * dt))

# Smoothly moves from one Vector3 to another, frame-rate independent.
static func move_vector3(from: Vector3, to: Vector3, speed: float, dt: float) -> Vector3:
	return from.lerp(to, 1.0 - exp(-speed * dt))

# Smoothly moves from one Vector2 to another, frame-rate independent.
static func move_vector2(from: Vector2, to: Vector2, speed: float, dt: float) -> Vector2:
	return from.lerp(to, 1.0 - exp(-speed * dt))

# Smoothly moves from one float to another, frame-rate independent.
static func move_float(from: float, to: float, speed: float, dt: float) -> float:
	return lerp(from, to, 1.0 - exp(-speed * dt))
