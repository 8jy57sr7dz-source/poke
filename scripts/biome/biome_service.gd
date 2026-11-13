extends Node3D

static func select_size(rng: RandomNumberGenerator) -> Dictionary:
	var sizes := [
		{"name": "Tiny", "weight": 5.0, "scale": 0.55},
		{"name": "Small", "weight": 15.0, "scale": 0.75},
		{"name": "Normal", "weight": 50.0, "scale": 1.0},
		{"name": "Large", "weight": 20.0, "scale": 1.25},
		{"name": "Huge", "weight": 8.0, "scale": 1.6},
		{"name": "Giant", "weight": 2.0, "scale": 2.0}
	]
	var total_weight := 0.0
	for size_data in sizes:
		total_weight += float(size_data.get("weight", 0.0))
	var roll := rng.randf_range(0.0, total_weight)
	var accumulated := 0.0
	for size_data in sizes:
		accumulated += float(size_data.get("weight", 0.0))
		if roll <= accumulated:
			return size_data
	return sizes[2]

static func select_mutation(rng: RandomNumberGenerator, rare: bool) -> String:
	var mutation_pool: Array = ["None"]
	if rare:
		mutation_pool = ["None", "Silver", "Golden", "Rainbow", "Bloom", "Spirit Bloom"]
	var weights := [90.0, 6.0, 2.5, 1.0, 0.4, 0.1]
	var total_weight := 0.0
	for weight in weights:
		total_weight += weight
	var roll := rng.randf_range(0.0, total_weight)
	var accumulated := 0.0
	for index in range(mutation_pool.size()):
		accumulated += weights[index]
		if roll <= accumulated:
			return str(mutation_pool[index])
	return "None"

static func create_creature(definition: Dictionary, rng: RandomNumberGenerator, rare: bool = false, biome_id: String = "meadow") -> Node3D:
	var creature := Node3D.new()
	creature.name = str(definition.get("id", "creature"))

	var visual := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.48
	mesh.height = 0.96
	visual.mesh = mesh
	visual.position.y = 0.48
	var color := Color(0.55, 0.8, 0.4)
	if rare:
		color = Color(0.95, 0.8, 0.2)
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	visual.material_override = material
	creature.add_child(visual)

	var size_data: Dictionary = select_size(rng)
	var size_name: String = str(size_data.get("name", "Normal"))
	var size_scale: float = float(size_data.get("scale", 1.0))
	creature.scale = Vector3.ONE * size_scale * float(definition.get("base_scale", 1.0))

	var mutation_name := select_mutation(rng, rare)
	var weight_kg := float(definition.get("weight_kg", 1.0)) * size_scale
	var base_income := float(definition.get("income_per_second", 1.0))
	var rarity_name := str(definition.get("rarity", "Common"))
	var shiny := rng.randf() <= 0.05 if rare else rng.randf() <= 0.005
	var record: Dictionary = definition.duplicate(true)
	record["biome_id"] = biome_id
	record["rarity"] = rarity_name
	record["size"] = size_name
	record["mutation"] = mutation_name
	record["shiny"] = shiny
	record["base_value"] = float(definition.get("base_value", 0.0))
	record["income_per_second"] = base_income
	creature.set_meta("pokemon_record", record)
	creature.set_meta("weight_kg", weight_kg)
	creature.set_meta("size", size_name)
	creature.set_meta("mutation", mutation_name)
	creature.set_meta("shiny", shiny)
	creature.set_meta("is_rare_event", rare)
	creature.set_meta("biome_id", biome_id)
	creature.set_meta("base_income_per_second", base_income)
	return creature
