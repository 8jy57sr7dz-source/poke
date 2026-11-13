extends SceneTree

func _initialize() -> void:
	var progression_path := "res://scripts/progression/progression_service.gd"
	var game_path := "res://scripts/game.gd"
	assert(FileAccess.file_exists(progression_path), "Progression service missing")
	assert(FileAccess.file_exists(game_path), "Game script missing")
	var progression_text := FileAccess.get_file_as_string(progression_path)
	assert(progression_text.contains("train_efficiency"), "Training efficiency missing")
	assert(progression_text.contains("speed_threshold_for_biome"), "Biome speed gate missing")
	var game_text := FileAccess.get_file_as_string(game_path)
	assert(game_text.contains("upgrade_base"), "Base upgrade missing")
	assert(game_text.contains("_refresh_biome_guardian"), "Biome refresh missing")
	print("Step 09 progression smoke checks passed by static validation.")
	quit()
