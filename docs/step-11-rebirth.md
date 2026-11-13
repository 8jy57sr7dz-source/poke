extends SceneTree

func _initialize() -> void:
	var rebirth_path := "res://scripts/rebirth/rebirth_service.gd"
	var game_path := "res://scripts/game.gd"
	assert(FileAccess.file_exists(rebirth_path), "Rebirth service missing")
	assert(FileAccess.file_exists(game_path), "Game script missing")
	var rebirth_text := FileAccess.get_file_as_string(rebirth_path)
	assert(rebirth_text.contains("can_rebirth"), "Rebirth eligibility missing")
	assert(rebirth_text.contains("reset_progress"), "Reset logic missing")
	var game_text := FileAccess.get_file_as_string(game_path)
	assert(game_text.contains("func rebirth()"), "Game rebirth action missing")
	assert(game_text.contains("permanent_bonus"), "Permanent bonus tracking missing")
	print("Step 11 rebirth smoke checks passed by static validation.")
	quit()
