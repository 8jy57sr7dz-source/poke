extends RefCounted

static func apply_mutation(record: Dictionary, mutation_id: String) -> Dictionary:
	var result := record.duplicate(true)
	result["mutation"] = mutation_id
	return result

static func is_shiny(record: Dictionary) -> bool:
	return bool(record.get("shiny", false))
