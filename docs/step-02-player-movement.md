extends SceneTree

func _initialize() -> void:
	var controller_path := "res://scripts/player/player_controller.gd"
	var game_path := "res://scripts/game.gd"
	assert(FileAccess.file_exists(controller_path), "Player controller missing")
	assert(FileAccess.file_exists(game_path), "Game script missing")
	var script_text := FileAccess.get_file_as_string(controller_path)
	assert(script_text.contains("_physics_process"), "player movement loop missing")
	assert(script_text.contains("KEY_E") and script_text.contains("KEY_T"), "interact/train controls missing")
	assert(FileAccess.get_file_as_string(game_path).contains("_build_world"), "world setup missing")
	print("Step 02 player movement smoke checks passed by static validation.")
	quit()
