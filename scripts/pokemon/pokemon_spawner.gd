extends Node3D

const PlayerController = preload("res://scripts/player/player_controller.gd")
const PokemonSpawner = preload("res://scripts/pokemon/pokemon_spawner.gd")
const Guardian = preload("res://scripts/guardian/guardian.gd")
const BiomeService = preload("res://scripts/biome/biome_service.gd")
const EconomyService = preload("res://scripts/economy/economy_service.gd")
const ProgressionService = preload("res://scripts/progression/progression_service.gd")
const SaveService = preload("res://scripts/save/save_service.gd")

var coins: float = 0.0
var speed_stat: float = 0.0
var carried: Node3D
var placed: Array[Dictionary] = []
var pokemon_definitions: Dictionary = {}
var economy_config: Dictionary = {}
var biome_data: Dictionary = {}
var rarity_timer: float = 0.0
var guardian: Node3D
var player: CharacterBody3D
var active_biome_id: String = "meadow"

func _ready() -> void:
	add_to_group("game_manager")
	_load_game_data()
	_build_world()
	_refresh_biome_guardian()
	_spawn_wild_creature()
	_update_hud()

func _process(delta: float) -> void:
	coins += _placed_income() * delta
	rarity_timer += delta
	if rarity_timer >= 300.0:
		rarity_timer = 0.0
		_spawn_wild_creature(true)
	if carried != null and guardian != null and is_instance_valid(guardian) and player != null:
		guardian.set_target(player.global_position)
		if guardian.global_position.distance_to(player.global_position) < 1.1:
			_drop_carried()
	if carried != null and player != null and player.global_position.distance_to(Vector3.ZERO) < 2.2:
		_deliver_carried()
	_refresh_biome_guardian()
	_update_hud()

func _load_game_data() -> void:
	var raw: Dictionary = _read_json("res://data/pokemon.json")
	var entries: Array = raw.get("entries", [])
	pokemon_definitions.clear()
	for entry in entries:
		if entry is Dictionary:
			pokemon_definitions[str(entry.get("id", ""))] = entry
	economy_config = _read_json("res://data/economy.json")
	biome_data = _read_json("res://data/biomes.json")
	var save_data: Dictionary = SaveService.load_data()
	coins = float(save_data.get("coins", 0.0))
	speed_stat = float(save_data.get("speed", 0.0))

func _build_world() -> void:
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(30.0, 30.0)
	floor.mesh = plane
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.20, 0.38, 0.23)
	floor.material_override = floor_material
	add_child(floor)

	_add_marker(Vector3.ZERO, Vector3(4.0, 0.15, 4.0), Color(0.2, 0.5, 0.9), "Safe Base")
	_add_marker(Vector3(-3.0, 0.15, 0.0), Vector3(2.0, 0.3, 1.0), Color(0.9, 0.6, 0.1), "Treadmill")

	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0.0, 0.1, 3.5)
	player.set_script(PlayerController)
	add_child(player)

	var capsule := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.35
	body_mesh.height = 1.8
	capsule.mesh = body_mesh
	capsule.position.y = 0.9
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.25, 0.65, 0.95)
	capsule.material_override = material
	player.add_child(capsule)

	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 12.0, 15.0)
	camera.rotation_degrees = Vector3(-35.0, 0.0, 0.0)
	camera.current = true
	player.add_child(camera)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55.0, -25.0, 0.0)
	light.shadow_enabled = true
	add_child(light)

	guardian = Guardian.new()
	guardian.name = "Guardian"
	guardian.position = Vector3(8.0, 0.0, 0.0)
	add_child(guardian)

func _refresh_biome_guardian() -> void:
	if biome_data.is_empty():
		return
	var unlocked := BiomeService.unlocked_biomes(biome_data, speed_stat)
	if unlocked.is_empty():
		return
	var next_biome: Dictionary = unlocked.back()
	var next_id := str(next_biome.get("id", active_biome_id))
	if next_id == active_biome_id and guardian != null:
		return
	active_biome_id = next_id
	if guardian != null:
		guardian.set_guardian_profile(next_biome.get("guardian", {}))
		guardian.position = Vector3(8.0, 0.0, 0.0)

func try_interact() -> void:
	if carried != null or player == null:
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
	if nearest == null:
		return
	carried = nearest
	carried.remove_from_group("wild_pokemon")
	carried.reparent(player)
	carried.position = Vector3(0.0, 1.6, -0.8)
	carried.set_meta("is_carried", true)
	_update_hud()

func train() -> void:
	if player == null:
		return
	if player.global_position.distance_to(Vector3(-3.0, 0.0, 0.0)) < 2.0:
		speed_stat = ProgressionService.train(speed_stat, float(economy_config.get("treadmill_speed_per_second", 0.25)), 0.1)
		_refresh_biome_guardian()
		_save()

func _deliver_carried() -> void:
	if carried == null:
		return
	var record: Dictionary = carried.get_meta("pokemon_record", {})
	record["size"] = carried.get_meta("size", "Normal")
	record["mutation"] = carried.get_meta("mutation", "None")
	record["shiny"] = carried.get_meta("shiny", false)
	placed.append(record)
	carried.queue_free()
	carried = null
	_save()
	_spawn_wild_creature()

func _drop_carried() -> void:
	if carried == null:
		return
	var dropped := carried
	carried = null
	dropped.reparent(self)
	dropped.set_meta("is_carried", false)
	dropped.position = player.position + Vector3(0.0, 0.35, 1.2)
	dropped.add_to_group("wild_pokemon")
	if guardian != null:
		guardian.set_target(Vector3(8.0, 0.0, 0.0))

func _spawn_wild_creature(rare: bool = false) -> void:
	if pokemon_definitions.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var spawn_id := active_biome_id
	var selected_definition: Dictionary = {}
	var biome: Dictionary = BiomeService.biome_by_id(biome_data, spawn_id)
	if not biome.is_empty():
		var table: Array = BiomeService.spawn_table_for(biome)
		if not table.is_empty():
			var selected_entry: Dictionary = BiomeService.weighted_spawn_entry(table, rng)
			var pokemon_id := str(selected_entry.get("pokemon_id", ""))
			if not pokemon_id.is_empty():
				selected_definition = pokemon_definitions.get(pokemon_id, {})
	if selected_definition.is_empty():
		var ids := pokemon_definitions.keys()
		var chosen_id := str(ids[rng.randi_range(0, ids.size() - 1)])
		selected_definition = pokemon_definitions.get(chosen_id, {})
	if selected_definition.is_empty():
		return
	var spawner := PokemonSpawner.new()
	var creature := spawner.create_creature(selected_definition, rng, rare, spawn_id)
	creature.position = Vector3(rng.randf_range(-10.0, 10.0), 0.45, rng.randf_range(-10.0, 10.0))
	add_child(creature)
	creature.add_to_group("wild_pokemon")

func _placed_income() -> float:
	var total := 0.0
	for record in placed:
		total += EconomyService.income_per_second(record, economy_config)
	return total

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
	var holding := "None"
	if carried != null:
		holding = str(carried.get_meta("pokemon_record", {}).get("name", "Creature"))
	var title := "Coins: %d | Speed: %.1f | Biome: %s | Carrying: %s | WASD move · E interact · T train" % [int(coins), speed_stat, active_biome_id, holding]
	if get_window() != null:
		get_window().title = title

func _save() -> void:
	SaveService.save_data({"coins": coins, "speed": speed_stat, "placed": placed})

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var text := FileAccess.get_file_as_string(path)
	if text == "":
		return {}
	var parsed: Variant = JSON.parse_string(text)
	return parsed if parsed is Dictionary else {}
