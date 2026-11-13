extends RefCounted

static func reward(rebirth_count: int, base_reward: float) -> float:
	return base_reward * (1.0 + maxf(rebirth_count, 0) * 0.1)

static func requirement(rebirth_count: int) -> float:
	return 100.0 * pow(2.0, maxf(float(rebirth_count), 0.0))

static func can_rebirth(speed: float, rebirth_count: int) -> bool:
	return speed >= requirement(rebirth_count)

static func reset_progress(save_data: Dictionary) -> Dictionary:
	var result := save_data.duplicate(true)
	var old_count := int(result.get("rebirths", 0))
	result["coins"] = 0.0
	result["speed"] = 0.0
	result["placed"] = []
	result["base_level"] = 1
	result["base_slots"] = 5
	result["rebirths"] = old_count + 1
	result["permanent_bonus"] = float(result.get("permanent_bonus", 1.0)) + 0.1
	return result
