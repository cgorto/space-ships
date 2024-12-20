class_name ProjectileData extends RefCounted

signal hit(thing_hit: Hurtbox)

var body: RID
var shape: RID
var multimesh: MultiMesh
var instance_id: int
var velocity: Vector3
var damage: float
var faction: int
var start_pos: Vector3
var lifetime: float
var lived: float
var ignored: Array[RID]
var position: Vector3
