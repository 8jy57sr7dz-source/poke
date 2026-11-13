extends RefCounted

static func register_capture(index: Dictionary, record: Dictionary) -> Dictionary:
	var result := index.duplicate(true)
	var pokemon_id := str(record.get("id", ""))
	if pokemon_id.is_empty():
		return result
	if not result.has(pokemon_id):
		result[pokemon_id] = {"count": 0, "shiny": false, "mutations": [], "max_size": "Tiny"}
	var entry: Dictionary = result[pokemon_id]
	entry["count"] = int(entry.get("count", 0)) + 1
	entry["shiny"] = bool(entry.get("shiny", false)) or bool(record.get("shiny", false))
	var mutation := str(record.get("mutation", "None"))
	var mutations: Array = entry.get("mutations", [])
	if mutation != "None" and not mutations.has(mutation): mutations.append(mutation)
	entry["mutations"] = mutations
	result[pokemon_id] = entry
	return result
