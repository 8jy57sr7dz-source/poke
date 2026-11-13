extends RefCounted

static func choose_weighted(entries: Array, rng: RandomNumberGenerator) -> Dictionary:
	var total := 0.0
	for entry in entries:
		total += maxf(float(entry.get("weight", 0.0)), 0.0)
	if total <= 0.0:
		return {}
	var roll := rng.randf() * total
	for entry in entries:
		roll -= maxf(float(entry.get("weight", 0.0)), 0.0)
		if roll < 0.0:
			return entry
	return entries.back()

static func validate_table(entries: Array) -> bool:
	if entries.is_empty():
		return false
	var total := 0.0
	for entry in entries:
		var weight := float(entry.get("weight", -1.0))
		if weight < 0.0:
			return false
		total += weight
	return total > 0.0

static func rare_interval_seconds() -> int:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/probabilities.json"))
	return int(parsed.get("rare_spawn_interval_seconds", 300)) if parsed is Dictionary else 300
