extends SceneTree

func _initialize() -> void:
	var biome_path := "res://data/biomes.json"
	var guardian_path := "res://scripts/guardian/guardian.gd"
	var biome_service_path := "res://scripts/biome/biome_service.gd"
	assert(FileAccess.file_exists(biome_path), "Biome data missing")
	assert(FileAccess.file_exists(guardian_path), "Guardian script missing")
	assert(FileAccess.file_exists(biome_service_path), "Biome service missing")
	var biome_text := FileAccess.get_file_as_string(biome_path)
	assert(biome_text.contains("\"id\": \"meadow\""), "Meadow biome missing")
	assert(biome_text.contains("\"guardian\""), "Guardian metadata missing")
	var guardian_text := FileAccess.get_file_as_string(guardian_path)
	assert(guardian_text.contains("set_guardian_profile"), "Guardian profile API missing")
	assert(guardian_text.contains("detection_range"), "Guard detection range missing")
	print("Step 03 biome and guardian smoke checks passed by static validation.")
	quit()
