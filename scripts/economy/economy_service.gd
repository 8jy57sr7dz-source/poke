extends RefCounted

static func income_per_second(record: Dictionary, config: Dictionary) -> float:
	var size_multipliers: Dictionary = config.get("size_multipliers", {})
	var mutation_multipliers: Dictionary = config.get("mutation_multipliers", {})
	var base := float(record.get("income_per_second", 0.0))
	var size_factor := float(size_multipliers.get(str(record.get("size", "Normal")), 1.0))
	var mutation_factor := float(mutation_multipliers.get(str(record.get("mutation", "None")), 1.0))
	return base * size_factor * mutation_factor * float(record.get("other_bonus", 1.0))

static func offline_income(rate: float, elapsed_seconds: float, cap_seconds: float) -> float:
	return rate * clampf(elapsed_seconds, 0.0, cap_seconds)
