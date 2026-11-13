extends RefCounted

static func train(current_speed: float, rate: float, elapsed: float) -> float:
	return current_speed + maxf(rate, 0.0) * maxf(elapsed, 0.0)

static func can_escape(player_speed: float, guardian_speed: float) -> bool:
	return player_speed > guardian_speed

static func rebirth_requirement(rebirth_count: int) -> float:
	return 100.0 * pow(2.0, rebirth_count)
