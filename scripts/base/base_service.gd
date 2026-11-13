extends RefCounted

static func has_free_slot(placed_count: int, slot_limit: int) -> bool:
	return placed_count < slot_limit

static func slot_limit(base_level: int, base_slots: int) -> int:
	return base_slots + maxi(base_level - 1, 0) * 2

static func upgrade_cost(level: int, base_cost: float) -> float:
	return base_cost * pow(1.6, maxi(level - 1, 0))

static func can_place(placed_count: int, base_level: int, base_slots: int) -> bool:
	return has_free_slot(placed_count, slot_limit(base_level, base_slots))
