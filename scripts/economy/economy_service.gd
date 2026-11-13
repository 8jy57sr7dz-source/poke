extends RefCounted

static func size_multiplier(size_key: String, config: Dictionary) -> float:
	var size_multipliers: Dictionary = config.get("size_multipliers", {})
	return float(size_multipliers.get(size_key, 1.0))

static func mutation_multiplier(mutation_key: String, config: Dictionary) -> float:
	var mutation_multipliers: Dictionary = config.get("mutation_multipliers", {})
	return float(mutation_multipliers.get(mutation_key, 1.0))

static func income_per_second(record: Dictionary, config: Dictionary) -> float:
	var base := float(record.get("income_per_second", 0.0))
	var size_factor := size_multiplier(str(record.get("size", "Normal")), config)
	var mutation_factor := mutation_multiplier(str(record.get("mutation", "None")), config)
	return base * size_factor * mutation_factor * float(record.get("other_bonus", 1.0))

static func offline_income(rate: float, elapsed_seconds: float, cap_seconds: float) -> float:
	return rate * clampf(elapsed_seconds, 0.0, cap_seconds)

static func base_upkeep_cost(level: int, base_cost: float) -> float:
	return base_cost * pow(1.6, maxf(level - 1, 0.0))
