extends RefCounted

static func validate_spawn(definition: Dictionary, biome_id: String) -> bool:
	return not definition.is_empty() and str(definition.get("biome", "")) == biome_id

static func unique_instance_id() -> String:
	return "%s-%s" % [Time.get_unix_time_from_system(), randi()]
