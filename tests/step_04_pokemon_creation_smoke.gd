extends RefCounted

static func is_unlocked(speed: float, required_speed: float) -> bool:
	return speed >= required_speed

static func biome_by_id(data: Dictionary, biome_id: String) -> Dictionary:
	for biome in data.get("biomes", []):
		if str(biome.get("id", "")) == biome_id:
			return biome
	return {}

static func unlocked_biomes(data: Dictionary, speed: float) -> Array:
	var result: Array = []
	for biome in data.get("biomes", []):
		var required := float(biome.get("speed_required", 0.0))
		if is_unlocked(speed, required):
			result.append(biome)
	return result

static func spawn_table_for(biome: Dictionary) -> Array:
	return biome.get("spawn_table", [])

static func weighted_spawn_entry(table: Array, rng: RandomNumberGenerator) -> Dictionary:
	if table.is_empty():
		return {}
	var total_weight := 0.0
	for entry in table:
		total_weight += float(entry.get("weight", 0.0))
	var roll := rng.randf_range(0.0, total_weight)
	var accum := 0.0
	for entry in table:
		accum += float(entry.get("weight", 0.0))
		if roll <= accum:
			return entry
	return table.back()
