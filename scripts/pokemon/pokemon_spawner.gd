extends RefCounted

static func create_creature(definition: Dictionary, rng: RandomNumberGenerator, rare: bool = false, biome_id: String = "meadow") -> Node3D:
	var creature := Node3D.new()
	creature.name = str(definition.get("id", "creature"))

	var visual := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.48
	mesh.height = 0.96
	visual.mesh = mesh
	visual.position.y = 0.48
	var color := Color(0.95, 0.8, 0.2) if rare else Color(0.55, 0.8, 0.4)
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	visual.material_override = material
	creature.add_child(visual)

	var sizes := [
		{"name": "Tiny", "weight": 5.0, "scale": 0.55},
		{"name": "Small", "weight": 15.0, "scale": 0.75},
		{"name": "Normal", "weight": 50.0, "scale": 1.0},
		{"name": "Large", "weight": 20.0, "scale": 1.25},
		{"name": "Huge", "weight": 8.0, "scale": 1.6},
		{"name": "Giant", "weight": 2.0, "scale": 2.0}
	]
	var size_data: Dictionary = _weighted_entry(sizes, rng)
	var size_name := str(size_data.get("name", "Normal"))
	var size_scale := float(size_data.get("scale", 1.0))
	creature.scale = Vector3.ONE * size_scale * float(definition.get("base_scale", 1.0))

	var mutation_name := "None"
	if rare:
		var mutations := [
			{"name": "None", "weight": 90.0},
			{"name": "Silver", "weight": 6.0},
			{"name": "Golden", "weight": 2.5},
			{"name": "Rainbow", "weight": 1.0},
			{"name": "Bloom", "weight": 0.4},
			{"name": "Spirit Bloom", "weight": 0.1}
		]
		mutation_name = str(_weighted_entry(mutations, rng).get("name", "None"))

	var base_income := float(definition.get("income_per_second", 1.0))
	var shiny := rng.randf() <= (0.05 if rare else 0.005)
	var record: Dictionary = definition.duplicate(true)
	record["biome_id"] = biome_id
	record["size"] = size_name
	record["mutation"] = mutation_name
	record["shiny"] = shiny
	record["income_per_second"] = base_income
	creature.set_meta("pokemon_record", record)
	creature.set_meta("weight_kg", float(definition.get("weight_kg", 1.0)) * size_scale)
	creature.set_meta("size", size_name)
	creature.set_meta("mutation", mutation_name)
	creature.set_meta("shiny", shiny)
	creature.set_meta("is_rare_event", rare)
	creature.set_meta("biome_id", biome_id)
	creature.set_meta("base_income_per_second", base_income)
	return creature

static func _weighted_entry(entries: Array, rng: RandomNumberGenerator) -> Dictionary:
	var total_weight := 0.0
	for value in entries:
		if value is Dictionary:
			total_weight += maxf(float(value.get("weight", 0.0)), 0.0)
	if total_weight <= 0.0:
		return {}
	var roll := rng.randf_range(0.0, total_weight)
	var accumulated := 0.0
	for value in entries:
		if not value is Dictionary:
			continue
		var entry: Dictionary = value
		accumulated += maxf(float(entry.get("weight", 0.0)), 0.0)
		if roll <= accumulated:
			return entry
	return {}
