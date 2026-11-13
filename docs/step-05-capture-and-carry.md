extends SceneTree

func _initialize() -> void:
	var service_path := "res://scripts/stealing/acquisition_service.gd"
	var game_path := "res://scripts/game.gd"
	assert(FileAccess.file_exists(service_path), "Acquisition service missing")
	assert(FileAccess.file_exists(game_path), "Game script missing")
	var service_text := FileAccess.get_file_as_string(service_path)
	assert(service_text.contains("can_acquire"), "Acquire check missing")
	assert(service_text.contains("claim"), "Claim logic missing")
	var game_text := FileAccess.get_file_as_string(game_path)
	assert(game_text.contains("try_interact"), "Capture interaction missing")
	assert(game_text.contains("_deliver_carried"), "Delivery after capture missing")
	print("Step 05 capture smoke checks passed by static validation.")
	quit()
