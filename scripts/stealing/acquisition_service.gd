extends RefCounted

static func can_acquire(is_claimed: bool, player_id: int, owner_id: int = -1) -> bool:
	return not is_claimed and (owner_id == -1 or owner_id == player_id)

static func claim(record: Dictionary, player_id: int) -> Dictionary:
	if bool(record.get("claimed", false)):
		return {}
	var updated := record.duplicate(true)
	updated["claimed"] = true
	updated["carrier_id"] = player_id
	return updated

static func spawn_claim_marker(position: Vector3) -> Dictionary:
	return {"position": position, "claimed": true}
