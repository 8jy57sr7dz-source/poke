extends Node3D

const PlayerController = preload("res://scripts/player/player_controller.gd")
const PokemonSpawner = preload("res://scripts/pokemon/pokemon_spawner.gd")
const Guardian = preload("res://scripts/guardian/guardian.gd")
const BiomeService = preload("res://scripts/biome/biome_service.gd")
const AcquisitionService = preload("res://scripts/stealing/acquisition_service.gd")
const CarryService = preload("res://scripts/carrying/carry_service.gd")
const EconomyService = preload("res://scripts/economy/economy_service.gd")
const ProgressionService = preload("res://scripts/progression/progression_service.gd")
const SaveService = preload("res://scripts/save/save_service.gd")
const BaseService = preload("res://scripts/base/base_service.gd")

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
var active_biome_id := "meadow"
var base_level := 1
var base_slots := 5
var _interference_cooldown := 0.0

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
	_interference_cooldown = maxf(_interference_cooldown - delta, 0.0)
	if rarity_timer >= 300.0:
		rarity_timer = 0.0
		_spawn_wild_creature(true)
	if carried != null and is_instance_valid(carried) and player != null:
		if guardian != null and is_instance_valid(guardian):
			guardian.set_target(player if carried != null else null)
			if guardian.global_position.distance_to(player.global_position) <= float(guardian.get("attack_range")):
				_drop_carried()
		if carried != null and CarryService.can_deliver(player.global_position.distance_to(Vector3.ZERO)):
			_deliver_carried()
	_update_hud()

func _load_game_data() -> void:
	var entries: Array = _read_json("res://data/pokemon.json").get("entries", [])
	for entry in entries:
		if entry is Dictionary:
			pokemon_definitions[str(entry.get("id", ""))] = entry
	economy_config = _read_json("res://data/economy.json")
	biome_data = _read_json("res://data/biomes.json")
	var saved := SaveService.load_data()
	coins = float(saved.get("coins", 0.0))
	speed_stat = float(saved.get("speed", 0.0))
	placed = saved.get("placed", [])
	base_level = max(int(saved.get("base_level", 1)), 1)
	base_slots = max(int(saved.get("base_slots", 5)), 1)

func _build_world() -> void:
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(30.0, 30.0)
	floor.mesh = plane
	var ground := StandardMaterial3D.new()
	ground.albedo_color = Color(0.20, 0.38, 0.23)
	floor.material_override = ground
	add_child(floor)
	_add_marker(Vector3.ZERO, Vector3(4.0, 0.15, 4.0), Color(0.2, 0.5, 0.9), "Safe Base")
	_add_marker(Vector3(-3.0, 0.15, 0.0), Vector3(2.0, 0.3, 1.0), Color(0.9, 0.6, 0.1), "Treadmill")
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0.0, 0.1, 3.5)
	player.set_script(PlayerController)
	player.add_to_group("players")
	add_child(player)
	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.35
	capsule.height = 1.8
	body.mesh = capsule
	body.position.y = 0.9
	var body_material := StandardMaterial3D.new()
	body_material.albedo_color = Color(0.25, 0.65, 0.95)
	body.material_override = body_material
	player.add_child(body)
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
	var unlocked := BiomeService.unlocked_biomes(biome_data, speed_stat)
	if unlocked.is_empty():
		return
	var biome: Dictionary = unlocked.back()
	var biome_id := str(biome.get("id", "meadow"))
	if biome_id == active_biome_id:
		return
	active_biome_id = biome_id
	if guardian != null:
		guardian.set_guardian_profile(biome.get("guardian", {}))

func try_interact() -> void:
	if carried != null or player == null:
		return
	var nearest: Node3D
	var nearest_distance := 2.6
	for candidate in get_tree().get_nodes_in_group("wild_pokemon"):
		if is_instance_valid(candidate):
			var distance := player.global_position.distance_to(candidate.global_position)
			if distance < nearest_distance:
				nearest = candidate
				nearest_distance = distance
	if nearest == null:
		return
	var claim := AcquisitionService.claim(nearest.get_meta("pokemon_record", {}), player.get_instance_id())
	if claim.is_empty():
		return
	carried = nearest
	carried.remove_from_group("wild_pokemon")
	carried.reparent(player)
	carried.position = Vector3(0.0, 1.6, -0.8)
	carried.set_meta("is_carried", true)
	carried.set_meta("claim_record", claim)
	if guardian != null:
		guardian.set_target(player)

func train() -> void:
	if player != null and player.global_position.distance_to(Vector3(-3.0, 0.0, 0.0)) < 2.0:
		speed_stat = ProgressionService.train(speed_stat, float(economy_config.get("treadmill_speed_per_second", 0.25)), 0.1)
		_refresh_biome_guardian()
		_save()

func apply_interference(attacker: Node3D) -> bool:
	if carried == null or not is_instance_valid(attacker) or _interference_cooldown > 0.0:
		return false
	if attacker == player or not attacker.is_in_group("players"):
		return false
	if attacker.global_position.distance_to(player.global_position) > 2.0:
		return false
	_interference_cooldown = 1.5
	_drop_carried()
	return true

func _deliver_carried() -> void:
	if carried == null:
		return
	if not BaseService.can_place(placed.size(), base_level, base_slots):
		return
	var record: Dictionary = carried.get_meta("pokemon_record", {}).duplicate(true)
	record["size"] = carried.get_meta("size", "Normal")
	record["mutation"] = carried.get_meta("mutation", "None")
	record["shiny"] = carried.get_meta("shiny", false)
	record["claimed"] = true
	placed.append(record)
	carried.queue_free()
	carried = null
	if guardian != null:
		guardian.clear_target()
	_save()
	_spawn_wild_creature()

func _drop_carried() -> void:
	if carried == null:
		return
	var dropped := carried
	carried = null
	dropped.reparent(self)
	dropped.set_meta("is_carried", false)
	dropped.set_meta("claim_record", {})
	dropped.position = player.position + Vector3(0.0, 0.35, 1.2)
	dropped.add_to_group("wild_pokemon")
	if guardian != null:
		guardian.clear_target()

func _spawn_wild_creature(rare: bool = false) -> void:
	if pokemon_definitions.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var biome: Dictionary = BiomeService.biome_by_id(biome_data, active_biome_id)
	var spawn_table: Array = BiomeService.spawn_table_for(biome)
	var definition: Dictionary
	if not spawn_table.is_empty():
		var entry: Dictionary = BiomeService.weighted_spawn_entry(spawn_table, rng)
		definition = pokemon_definitions.get(str(entry.get("pokemon_id", "")), {})
	if definition.is_empty():
		var ids := pokemon_definitions.keys()
		definition = pokemon_definitions.get(str(ids[rng.randi_range(0, ids.size() - 1)]), {})
	if definition.is_empty():
		return
	var creature := PokemonSpawner.create_creature(definition, rng, rare, active_biome_id)
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
	var slot_limit := BaseService.slot_limit(base_level, base_slots)
	var holding := "None" if carried == null else str(carried.get_meta("pokemon_record", {}).get("name", "Creature"))
	if get_window() != null:
		get_window().title = "Coins: %d | Speed: %.1f | Base Lv: %d/%d | Biome: %s | Carrying: %s | WASD · E interact · T train" % [int(coins), speed_stat, base_level, slot_limit, active_biome_id, holding]

func _save() -> void:
	SaveService.save_data({"coins": coins, "speed": speed_stat, "placed": placed, "base_level": base_level, "base_slots": base_slots})

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}
