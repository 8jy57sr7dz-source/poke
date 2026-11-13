extends RefCounted

static func capture_entry(index: Dictionary, pokemon_id: String, record: Dictionary) -> Dictionary:
	var entries: Dictionary = index.get("entries", {})
	if entries.has(pokemon_id):
		var current: Dictionary = entries[pokemon_id]
		if bool(record.get("shiny", false)):
			current["shiny_seen"] = true
		current["seen_count"] = int(current.get("seen_count", 0)) + 1
		current["name"] = str(record.get("name", current.get("name", pokemon_id)))
		entries[pokemon_id] = current
		index["entries"] = entries
		return index
	var next: Dictionary = {
		"pokemon_id": pokemon_id,
		"name": str(record.get("name", pokemon_id)),
		"seen_count": 1,
		"captured": bool(record.get("claimed", false)),
		"shiny_seen": bool(record.get("shiny", false)),
		"last_biome": str(record.get("biome_id", "meadow"))
	}
	entries[pokemon_id] = next
	index["entries"] = entries
	return index

static func seen_count(index: Dictionary) -> int:
	return int(index.get("total_seen", 0))

static func completion_ratio(index: Dictionary) -> float:
	var entries: Dictionary = index.get("entries", {})
	if entries.is_empty():
		return 0.0
	var total := 0.0
	for key in entries.keys():
		var entry: Dictionary = entries.get(key, {})
		if bool(entry.get("captured", false)):
			total += 1.0
	return total / float(max(entries.size(), 1))

static func is_captured(index: Dictionary, pokemon_id: String) -> bool:
	var entries: Dictionary = index.get("entries", {})
	var entry: Dictionary = entries.get(pokemon_id, {})
	return bool(entry.get("captured", false))

static func add_seen(index: Dictionary, pokemon_id: String, record: Dictionary) -> Dictionary:
	var new_index: Dictionary = index.duplicate(true)
	new_index = capture_entry(new_index, pokemon_id, record)
	new_index["total_seen"] = int(new_index.get("total_seen", 0)) + 1
	return new_index
