extends Node3D

const PlayerController = preload("res://scripts/player/player_controller.gd")
const PokemonSpawner = preload("res://scripts/pokemon/pokemon_spawner.gd")
const Guardian = preload("res://scripts/guardian/guardian.gd")
const ProbabilityEngine = preload("res://scripts/probability/probability_engine.gd")
const EconomyService = preload("res://scripts/economy/economy_service.gd")
const ProgressionService = preload("res://scripts/progression/progression_service.gd")
const SaveService = preload("res://scripts/save/save_service.gd")

var coins: float = 0.0
var speed_stat: float = 0.0
var carried: Node3D = null
var placed: Array[Dictionary] = []
var pokemon_definitions: Dictionary = {}
var economy_config: Dictionary = {}
var rarity_timer: float = 0.0
var guardian: Node3D
var player: CharacterBody3D

func _ready() -> void:
	add_to_group("game_manager")
	pokemon_definitions = _read_json("res://data/pokemon.json").get("entries", [])
	economy_config = _read_json("res://data/economy.json")
	coins = float(SaveService.load_data().get("coins", 0.0))
	speed_stat = float(SaveService.load_data().get("speed", 0.0))
	_build_graybox()
	guardian = Guardian.new()
	guardian.name = "Guardian"
	guardian.position = Vector3(8.0, 0.0, 0.0)
	add_child(guardian)
	_spawn_creature()
	_update_hud()

func _process(delta: float) -> void:
	coins += _placed_income() * delta
	rarity_timer += delta
	if rarity_timer >= float(ProbabilityEngine.rare_interval_seconds()):
		rarity_timer = 0.0
		_spawn_creature(true)
	if carried != null and is_instance_valid(guardian):
		guardian.set_target(player.global_position)
		if guardian.global_position.distance_to(player.global_position) < 1.1:
			_drop_carried()
	if carried != null and player.global_position.distance_to(Vector3.ZERO) < 2.2:
		_deliver_carried()
	_update_hud()

func _physics_process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_T) and player.global_position.distance_to(Vector3(-3.0, 0.0, 0.0)) < 2.0:
		speed_stat += float(economy_config.get("treadmill_speed_per_second", 0.25)) * get_physics_process_delta_time()

func try_interact() -> void:
	if carried != null:
		return
	var nearest: Node3D
	var nearest_distance := 2.6
	for candidate in get_tree().get_nodes_in_group("wild_pokemon"):
		if not is_instance_valid(candidate):
			continue
		var distance := player.global_position.distance_to(candidate.global_position)
		if distance < nearest_distance:
			nearest = candidate
			nearest_distance = distance
	if nearest != null:
		carried = nearest
		carried.remove_from_group("wild_pokemon")
		carried.set_meta("carrier", player.get_instance_id())
		carried.reparent(player)
		carried.position = Vector3(0.0, 1.6, -0.8)
		carried.set_meta("is_carried", true)
		_update_hud()

func train() -> void:
	if player.global_position.distance_to(Vector3(-3.0, 0.0, 0.0)) < 2.0:
		speed_stat = ProgressionService.train(speed_stat, float(economy_config.get("treadmill_speed_per_second", 0.25)), 0.1)

func _deliver_carried() -> void:
	var record: Dictionary = carried.get_meta("pokemon_record", {})
	record["size"] = carried.get_meta("size", "Normal")
	record["mutation"] = carried.get_meta("mutation", "None")
	record["shiny"] = carried.get_meta("shiny", false)
	placed.append(record)
	carried.queue_free()
	carried = null
	_save()
	_spawn_creature()

func _drop_carried() -> void:
	if carried == null:
		return
	var dropped := carried
	carried = null
	dropped.reparent(self)
	dropped.remove_meta("carrier")
	dropped.set_meta("is_carried", false)
	dropped.position = player.position + Vector3(0.0, 0.35, 1.2)
	dropped.add_to_group("wild_pokemon")
	guardian.set_target(Vector3(8.0, 0.0, 0.0))

func _spawn_creature(rare: bool = false) -> void:
	var spawner := PokemonSpawner.new()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var ids: Array = pokemon_definitions.keys()
	if ids.is_empty():
		return
	var chosen_id: String = str(ids[rng.randi_range(0, ids.size() - 1)])
	var definition: Dictionary = pokemon_definitions[chosen_id]
	var creature := spawner.create_creature(definition, rng, rare)
	creature.position = Vector3(rng.randf_range(-10.0, 10.0), 0.45, rng.randf_range(-10.0, 10.0))
	add_child(creature)
	creature.add_to_group("wild_pokemon")

func _placed_income() -> float:
	var total := 0.0
	for record in placed:
		total += EconomyService.income_per_second(record, economy_config)
	return total

func _build_graybox() -> void:
	var floor := MeshInstance3D.new()
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(30.0, 30.0)
	floor.mesh = floor_mesh
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.20, 0.38, 0.23)
	floor.material_override = floor_material
	add_child(floor)
	_add_marker(Vector3.ZERO, Vector3(4.0, 0.15, 4.0), Color(0.2, 0.5, 0.9), "Safe Base")
	_add_marker(Vector3(-3.0, 0.15, 0.0), Vector3(2.0, 0.3, 1.0), Color(0.9, 0.6, 0.1), "Treadmill")
	player = CharacterBody3D.new()
	player.name = "Player"
	player.set_script(PlayerController)
	var visual := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.height = 1.8
	capsule.radius = 0.35
	visual.mesh = capsule
	visual.position.y = 0.9
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.25, 0.65, 0.95)
	visual.material_override = material
	player.add_child(visual)
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.height = 1.8
	shape.radius = 0.35
	collision.shape = shape
	collision.position.y = 0.9
	player.add_child(collision)
	player.position = Vector3(0.0, 0.1, 3.0)
	add_child(player)
	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 12.0, 15.0)
	camera.rotation_degrees = Vector3(-35.0, 0.0, 0.0)
	camera.current = true
	player.add_child(camera)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55.0, -25.0, 0.0)
	light.shadow_enabled = true
	add_child(light)

func _add_marker(at: Vector3, size: Vector3, color: Color, label: String) -> void:
	var marker := MeshInstance3D.new()
	marker.name = label
	var box := BoxMesh.new()
	box.size = size
	marker.mesh = box
	marker.position = at
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.55
	marker.material_override = material
	add_child(marker)

func _update_hud() -> void:
	var held := "None" if carried == null else str(carried.get_meta("pokemon_record", {}).get("name", "Creature"))
	var title := "Coins: %d | Speed: %.1f | Carrying: %s | WASD move · E interact · T train" % [int(coins), speed_stat, held]
	get_window().title = title

func _save() -> void:
	SaveService.save_data({"coins": coins, "speed": speed_stat, "placed": placed})

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}
