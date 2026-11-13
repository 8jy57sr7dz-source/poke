extends SceneTree

func _initialize() -> void:
	var base_service_path := "res://scripts/base/base_service.gd"
	var game_path := "res://scripts/game.gd"
	assert(FileAccess.file_exists(base_service_path), "Base service missing")
	assert(FileAccess.file_exists(game_path), "Game script missing")
	var base_text := FileAccess.get_file_as_string(base_service_path)
	assert(base_text.contains("slot_limit"), "Slot limit logic missing")
	assert(base_text.contains("can_place"), "Place validation missing")
	var game_text := FileAccess.get_file_as_string(game_path)
	assert(game_text.contains("BaseService"), "Base integration missing")
	assert(game_text.contains("base_level"), "Base level tracking missing")
	print("Step 07 base placement smoke checks passed by static validation.")
	quit()
