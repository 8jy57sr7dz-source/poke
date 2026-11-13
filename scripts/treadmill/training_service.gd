extends RefCounted

static func train(current_speed: float, speed_per_second: float, elapsed: float) -> float:
	return current_speed + maxf(speed_per_second, 0.0) * maxf(elapsed, 0.0)

static func upgrade_cost(level: int, base_cost: float) -> float:
	return base_cost * pow(1.6, maxi(level - 1, 0))
