extends RefCounted

static func reward(rebirth_count: int, base_reward: float) -> float:
	return base_reward * (1.0 + maxf(rebirth_count, 0) * 0.1)

static func reset_progress(save_data: Dictionary) -> Dictionary:
	var result := save_data.duplicate(true)
	result["coins"] = 0.0
	result["speed"] = 0.0
	result["placed"] = []
	result["rebirths"] = int(result.get("rebirths", 0)) + 1
	return result
