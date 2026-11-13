extends RefCounted

static func speed_multiplier(weight_kg: float, base_factor: float = 1.0) -> float:
	return clampf(base_factor / (1.0 + maxf(weight_kg, 0.0) * 0.035), 0.35, 1.0)

static func can_deliver(distance_to_safe_zone: float, radius: float = 2.2) -> bool:
	return distance_to_safe_zone <= radius

static func recovery_action(disconnected: bool) -> String:
	return "return_to_spawn" if disconnected else "drop_to_world"
