extends Node3D

@export var patrol_speed: float = 2.2
@export var chase_speed: float = 4.0
@export var detection_range: float = 8.0
@export var attack_range: float = 1.4
@export var roam_radius: float = 8.0
@export var guard_name: String = "Guardian"

var target: Node3D
var patrol_center: Vector3 = Vector3.ZERO
var is_chasing := false
var _patrol_phase := 0.0

func _ready() -> void:
	patrol_center = global_position

func set_guardian_profile(profile: Dictionary) -> void:
	if profile.is_empty():
		return
	guard_name = str(profile.get("name", guard_name))
	patrol_speed = maxf(float(profile.get("patrol_speed", patrol_speed)), 0.0)
	chase_speed = maxf(float(profile.get("chase_speed", chase_speed)), 0.0)
	detection_range = maxf(float(profile.get("detection_range", detection_range)), 0.0)
	attack_range = maxf(float(profile.get("attack_range", attack_range)), 0.1)
	roam_radius = maxf(float(profile.get("roam_radius", roam_radius)), 0.0)
	var p: Dictionary = profile.get("position", {})
	global_position = Vector3(float(p.get("x", global_position.x)), float(p.get("y", global_position.y)), float(p.get("z", global_position.z)))
	patrol_center = global_position
	name = guard_name

func set_target(candidate: Node3D) -> void:
	target = candidate

func clear_target() -> void:
	target = null
	is_chasing = false

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		var offset := target.global_position - global_position
		offset.y = 0.0
		var distance := offset.length()
		is_chasing = distance <= detection_range
		if is_chasing and distance > attack_range:
			global_position += offset.normalized() * chase_speed * delta
			return
	else:
		clear_target()
	is_chasing = false
	_patrol_phase += delta * 0.7
	var desired := patrol_center + Vector3(cos(_patrol_phase), 0.0, sin(_patrol_phase)) * roam_radius * 0.5
	var patrol_offset := desired - global_position
	patrol_offset.y = 0.0
	if patrol_offset.length() > 0.1:
		global_position += patrol_offset.normalized() * patrol_speed * delta
