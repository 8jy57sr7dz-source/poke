extends RefCounted

static func is_unlocked(speed: float, required_speed: float) -> bool:
	return speed >= required_speed

static func biome_by_id(data: Dictionary, biome_id: String) -> Dictionary:
	for biome in data.get("biomes", []):
		if str(biome.get("id", "")) == biome_id:
			return biome
	return {}
