extends SceneTree

func _initialize() -> void:
	var index_path := "res://scripts/index/index_service.gd"
	var game_path := "res://scripts/game.gd"
	assert(FileAccess.file_exists(index_path), "Index service missing")
	assert(FileAccess.file_exists(game_path), "Game script missing")
	var index_text := FileAccess.get_file_as_string(index_path)
	assert(index_text.contains("capture_entry"), "Pokedex entry capture missing")
	assert(index_text.contains("completion_ratio"), "Completion ratio missing")
	var game_text := FileAccess.get_file_as_string(game_path)
	assert(game_text.contains("pokedex"), "Pokedex state missing")
	assert(game_text.contains("IndexService"), "Pokedex service integration missing")
	print("Step 10 index smoke checks passed by static validation.")
	quit()
