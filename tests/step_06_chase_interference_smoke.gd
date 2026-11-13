extends SceneTree

func _initialize() -> void:
	var guardian_script := FileAccess.get_file_as_string("res://scripts/guardian/guardian.gd")
	var game_script := FileAccess.get_file_as_string("res://scripts/game.gd")
	assert(guardian_script.contains("detection_range"), "Guardian detection range missing")
	assert(guardian_script.contains("set_target(candidate"), "Guardian target API missing")
	assert(guardian_script.contains("clear_target"), "Guardian reset API missing")
	assert(game_script.contains("apply_interference"), "Interference handler missing")
	assert(game_script.contains("_drop_carried"), "Drop behavior missing")
	assert(game_script.contains("_interference_cooldown"), "Interference cooldown missing")
	print("Step 06 guardian chase and interference static checks passed.")
	quit()
