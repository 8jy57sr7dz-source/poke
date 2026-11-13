extends SceneTree

func _initialize() -> void:
	var economy_path := "res://scripts/economy/economy_service.gd"
	var game_path := "res://scripts/game.gd"
	assert(FileAccess.file_exists(economy_path), "Economy service missing")
	assert(FileAccess.file_exists(game_path), "Game script missing")
	var economy_text := FileAccess.get_file_as_string(economy_path)
	assert(economy_text.contains("income_per_second"), "Income formula missing")
	assert(economy_text.contains("offline_income"), "Offline income missing")
	var game_text := FileAccess.get_file_as_string(game_path)
	assert(game_text.contains("upgrade_base"), "Base upgrade hook missing")
	assert(game_text.contains("_placed_income"), "Automatic income loop missing")
	print("Step 08 economy and base upgrade smoke checks passed by static validation.")
	quit()
