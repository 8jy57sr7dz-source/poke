extends SceneTree

const ProbabilityEngine = preload("res://scripts/probability/probability_engine.gd")

func _initialize() -> void:
	var table := [{"id": "a", "weight": 1}, {"id": "b", "weight": 3}]
	assert(ProbabilityEngine.validate_table(table))
	assert(not ProbabilityEngine.validate_table([]))
	assert(not ProbabilityEngine.validate_table([{"id": "bad", "weight": -1}]))
	print("Probability smoke tests passed.")
	quit()
