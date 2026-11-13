extends RefCounted

static func unlocked_biomes(data: Dictionary, speed: float) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var biomes: Array = data.get("biomes", [])
	for value in biomes:
		if not value is Dictionary:
			continue
		var biome: Dictionary = value
		if speed >= float(biome.get("speed_required", 0.0)):
			result.append(biome)
	return result

static func biome_by_id(data: Dictionary, biome_id: String) -> Dictionary:
	for value in data.get("biomes", []):
		if value is Dictionary and str(value.get("id", "")) == biome_id:
			return value
	return {}

static func spawn_table_for(biome: Dictionary) -> Array:
	var table: Variant = biome.get("spawn_table", [])
	return table if table is Array else []

static func weighted_spawn_entry(spawn_table: Array, rng: RandomNumberGenerator) -> Dictionary:
	var total_weight := 0.0
	for value in spawn_table:
		if value is Dictionary:
			total_weight += maxf(float(value.get("weight", 0.0)), 0.0)
	if total_weight <= 0.0:
		return {}

	var roll := rng.randf_range(0.0, total_weight)
	var accumulated := 0.0
	for value in spawn_table:
		if not value is Dictionary:
			continue
		var entry: Dictionary = value
		accumulated += maxf(float(entry.get("weight", 0.0)), 0.0)
		if roll <= accumulated:
			return entry
	return {}
