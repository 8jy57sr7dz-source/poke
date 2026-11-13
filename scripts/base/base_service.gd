extends RefCounted

static func has_free_slot(placed_count: int, slot_limit: int) -> bool:
	return placed_count < slot_limit

static func slot_limit(base_level: int, base_slots: int) -> int:
	return base_slots + maxi(base_level - 1, 0) * 2
