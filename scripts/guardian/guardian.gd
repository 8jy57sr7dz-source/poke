extends Node3D

@export var patrol_speed: float = 2.2
@export var chase_speed: float = 4.0
@export var detection_range: float = 8.0
@export var attack_range: float = 1.4
@export var roam_radius: float = 8.0
@export var guard_name: String = "Guardian"

var target_position: Vector3 = Vector3.ZERO
var patrol_center: Vector3 = Vector3.ZERO
var is_chasing := false
var last_known_target: Vector3 = Vector3.ZERO

func _ready() -> void:
	patrol_center = global_position

func set_guardian_profile(profile: Dictionary) -> void:
	if profile.is_empty():
		return
	if profile.has("name"):
		guard_name = str(profile.get("name", guard_name))
	if profile.has("patrol_speed"):
		patrol_speed = float(profile.get("patrol_speed", patrol_speed))
	if profile.has("chase_speed"):
		chase_speed = float(profile.get("chase_speed", chase_speed))
	if profile.has("detection_range"):
		detection_range = float(profile.get("detection_range", detection_range))
	if profile.has("roam_radius"):
		roam_radius = float(profile.get("roam_radius", roam_radius))
	if profile.has("position"):
		var position_data: Dictionary = profile.get("position", {})
		global_position = Vector3(
			float(position_data.get("x", global_position.x)),
			float(position_data.get("y", global_position.y)),
			float(position_data.get("z", global_position.z))
		)
	patrol_center = global_position
	name = guard_name

func set_target(value: Vector3) -> void:
	target_position = value
	last_known_target = value
	is_chasing = true

func _physics_process(delta: float) -> void:
	if is_chasing:
		var offset := last_known_target - global_position
		offset.y = 0.0
		if offset.length() > attack_range:
			global_position += offset.normalized() * chase_speed * delta
		if offset.length() > detection_range * 1.5:
			is_chasing = false
		return
	var t := Time.get_ticks_msec() * 0.001
	var angle := sin(t * 0.7) * TAU
	var wander := Vector3(cos(angle), 0.0, sin(angle)) * roam_radius * 0.5
	var desired := patrol_center + wander
	var offset_2 := desired - global_position
	offset_2.y = 0.0
	if offset_2.length() > 0.1:
		global_position += offset_2.normalized() * patrol_speed * delta
