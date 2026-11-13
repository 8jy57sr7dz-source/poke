extends Node3D

@export var chase_speed: float = 3.0
var target_position: Vector3
var has_target := false

func set_target(value: Vector3) -> void:
	target_position = value
	has_target = true

func _physics_process(delta: float) -> void:
	if has_target:
		var offset := target_position - global_position
		offset.y = 0.0
		if offset.length() > 0.8:
			global_position += offset.normalized() * chase_speed * delta
