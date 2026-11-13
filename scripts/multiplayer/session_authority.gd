extends RefCounted

# This stub documents the server-authority boundary. Never trust client-supplied
# currency, rarity rolls, ownership, or speed in a real multiplayer deployment.
static func validate_server_claim(instance_id: String, player_id: int, claim_ledger: Dictionary) -> bool:
	return not instance_id.is_empty() and player_id > 0 and not claim_ledger.has(instance_id)

static func commit_claim(instance_id: String, player_id: int, claim_ledger: Dictionary) -> Dictionary:
	if not validate_server_claim(instance_id, player_id, claim_ledger):
		return claim_ledger.duplicate(true)
	var updated := claim_ledger.duplicate(true)
	updated[instance_id] = player_id
	return updated
