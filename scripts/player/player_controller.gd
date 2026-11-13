extends CharacterBody3D

@export var move_speed := 5.5
var game: Node

func _ready() -> void:
	game = get_tree().get_first_node_in_group("game_manager")
	if game == null:
		push_warning("PlayerController started without a Game node in the scene tree.")

func _physics_process(_delta: float) -> void:
	var direction := Vector3.ZERO
	if Input.is_physical_key_pressed(KEY_W):
		direction.z -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		direction.z += 1.0
	if Input.is_physical_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		direction.x += 1.0

	if direction == Vector3.ZERO:
		velocity = Vector3.ZERO
		return

	var current_speed := move_speed
	if game != null and is_instance_valid(game) and game.has_method("get") and game.get("carried") != null:
		var carried: Node3D = game.get("carried")
		var weight := float(carried.get_meta("weight_kg", 1.0))
		current_speed *= clampf(1.0 - weight * 0.015, 0.45, 0.95)

	var velocity_3d := direction.normalized() * current_speed
	velocity.x = velocity_3d.x
	velocity.z = velocity_3d.z
	velocity.y = 0.0
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event: InputEventKey = event
	if key_event.pressed and not key_event.echo and game != null:
		if key_event.physical_keycode == KEY_E:
			game.try_interact()
		elif key_event.physical_keycode == KEY_T:
			game.train()
