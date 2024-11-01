extends Object
class_name Util

# Smoothly rotates from one Quat to another, frame-rate independent.
static func qt_damp(from: Quaternion, to: Quaternion, speed: float, dt: float) -> Quaternion:
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

static func qt_look_at(forward: Vector3, up: Vector3) -> Quaternion:
	var f: Vector3 = forward.normalized()
	var r: Vector3 = up.cross(forward)
	var u: Vector3 = f.cross(r)
	#Ensure orthonormalality
	var m00: float = r.x
	var m01: float = r.y
	var m02: float = r.z
	var m10: float = u.x
	var m11: float = u.y
	var m12: float = u.z
	var m20: float = f.x
	var m21: float = f.y
	var m22: float = f.z
	
	var q: Quaternion = Quaternion.IDENTITY
	var trace: float = m00 + m11 + m22
	
	if trace > 0:
		var s: float = 0.5 / sqrt(trace + 1)
		q.w = 0.25 / s
		q.x = (m12 - m21) * s
		q.y = (m20 - m02) * s
		q.z = (m01 - m10) * s
		return q.normalized()
	elif ((m00 >= m11) && (m00 >= m22)):
		var s: float = 2 * sqrt(1 + m00 - m11 - m22)
		q.x = 0.25 * s
		q.y = (m01 + m10) / s
		q.z = (m02 + m20) /s
		q.w = (m12 - m21) / s
		return q.normalized()
	elif (m11 > m22):
		var s: float = 2* sqrt(1 + m11 - m00 - m22)
		q.x = (m10 + m01) / s
		q.y = 0.25 * s
		q.z = (m21 + m12) / s
		q.w = (m20 - m02) / s
		return q.normalized()
	else:
		var s: float = 2 * sqrt(1 + m22 - m00 - m11)
		q.x = (m20 + m02) / s
		q.y = (m21 + m12) / s
		q.z = 0.25 * s
		q.w = (m01 - m10) / s
		return q.normalized()
		

#static func calculate_lead(from: RigidBody3D, to: RigidBody3D, muzzle_velocity: float) -> Vector3:
	#var own_predicted_pos: Vector3 = from.global_position + from.linear_velocity
	#var target_predicted_pos: Vector3 = to.global_position + to.linear_velocity
	#
	#var range_to_target: float = own_predicted_pos.distance_to(target_predicted_pos)
	#var time_to_hit: float = range_to_target / muzzle_velocity
	#
	#var lead: Vector3 = (from.linear_velocity - to.linear_velocity) * time_to_hit + to.global_position
	#return lead
	#

static func calculate_lead(relative_pos: Vector3, relative_vel: Vector3, projectile_speed: float) -> float:
	var a: float = relative_vel.dot(relative_vel) - (projectile_speed ** 2)
	var b: float = 2 * relative_vel.dot(relative_pos)
	var c: float = relative_pos.dot(relative_pos)
	
	var p: float = -b / (2 * a)
	var q: float = sqrt((b*b) - 4 * a * c) / (2 * a)
	
	var t1: float = p - q
	var t2: float = p + q
	var time: float = t2 if (t1 > t2 && t2 > 0) else t1
	return time
	
	





static func uniform_random_vector() -> Vector3:
	var phi: float = randf_range(0,TAU)
	var costheta: float = randf_range(-1,1)
	var theta: float = acos(costheta)
	return Vector3(
		sin(theta) * cos(phi),
		sin(theta) * sin(phi),
		cos(theta)
		)
