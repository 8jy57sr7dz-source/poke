extends RefCounted

static func create_creature(definition: Dictionary, rng: RandomNumberGenerator, rare: bool = false, biome_id: String = "meadow", probability_config: Dictionary = {}) -> Node3D:
	var creature := Node3D.new()
	creature.name = str(definition.get("id", "creature"))

	var visual := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.48
	mesh.height = 0.96
	visual.mesh = mesh
	visual.position.y = 0.48
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.95, 0.8, 0.2) if rare else Color(0.55, 0.8, 0.4)
	visual.material_override = material
	creature.add_child(visual)

	var tables: Dictionary = probability_config.get("tables", {})
	var size_data := _weighted_entry(tables.get("size", []), rng, {"id": "Normal", "weight": 1, "scale": 1.0})
	var size_name := str(size_data.get("id", "Normal"))
	var size_scale := float(size_data.get("scale", _default_size_scale(size_name)))
	creature.scale = Vector3.ONE * size_scale * float(definition.get("base_scale", 1.0))

	var mutation_name := "None"
	if rare:
		var mutation_data := _weighted_entry(tables.get("mutation", []), rng, {"id": "None", "weight": 1})
		mutation_name = str(mutation_data.get("id", "None"))
	var shiny_data := _weighted_entry(tables.get("shiny", []), rng, {"id": "false", "weight": 1})
	var shiny := str(shiny_data.get("id", "false")).to_lower() == "true"

	var base_income := float(definition.get("income_per_second", 1.0))
	var record: Dictionary = definition.duplicate(true)
	record["biome_id"] = biome_id
	record["size"] = size_name
	record["mutation"] = mutation_name
	record["shiny"] = shiny
	record["income_per_second"] = base_income
	creature.set_meta("pokemon_record", record)
	creature.set_meta("weight_kg", float(definition.get("weight_kg", 1.0)) * size_scale)
	creature.set_meta("carry_speed_factor", float(definition.get("carry_speed_factor", 1.0)))
	creature.set_meta("size", size_name)
	creature.set_meta("mutation", mutation_name)
	creature.set_meta("shiny", shiny)
	creature.set_meta("is_rare_event", rare)
	creature.set_meta("biome_id", biome_id)
	creature.set_meta("base_income_per_second", base_income)
	return creature

static func _default_size_scale(size_name: String) -> float:
	match size_name:
		"Tiny": return 0.55
		"Small": return 0.75
		"Large": return 1.25
		"Huge": return 1.6
		"Giant": return 2.0
		_: return 1.0

static func _weighted_entry(entries: Variant, rng: RandomNumberGenerator, fallback: Dictionary) -> Dictionary:
	if not entries is Array:
		return fallback
	var total_weight := 0.0
	for value in entries:
		if value is Dictionary:
			total_weight += maxf(float(value.get("weight", 0.0)), 0.0)
	if total_weight <= 0.0:
		return fallback
	var roll := rng.randf_range(0.0, total_weight)
	var accumulated := 0.0
	for value in entries:
		if not value is Dictionary:
			continue
		var entry: Dictionary = value
		accumulated += maxf(float(entry.get("weight", 0.0)), 0.0)
		if roll <= accumulated:
			return entry
	return fallback
