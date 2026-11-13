extends CharacterBody3D

const WALK_SPEED := 5.5
var game: Node

func _ready() -> void:
	game = get_tree().get_first_node_in_group("game_manager")

func _physics_process(_delta: float) -> void:
	var direction := Vector3.ZERO
	if Input.is_key_pressed(KEY_W): direction.z -= 1.0
	if Input.is_key_pressed(KEY_S): direction.z += 1.0
	if Input.is_key_pressed(KEY_A): direction.x -= 1.0
	if Input.is_key_pressed(KEY_D): direction.x += 1.0
	direction = direction.normalized()
	var speed := WALK_SPEED
	if game != null and game.carried != null:
		var weight := float(game.carried.get_meta("weight_kg", 1.0))
		speed *= clampf(1.0 - weight * 0.015, 0.45, 0.95)
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	velocity.y = 0.0
	move_and_slide()
	if Input.is_key_pressed(KEY_E) and not Input.is_action_pressed("ui_accept"):
		if Input.is_key_pressed(KEY_SHIFT):
			return
		# E is edge-triggered in _unhandled_key_input below to avoid repeating.

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E and game != null:
			game.try_interact()
		elif event.keycode == KEY_T and game != null:
			game.train()
