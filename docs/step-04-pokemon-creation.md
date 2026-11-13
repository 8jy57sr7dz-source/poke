extends SceneTree

func _initialize() -> void:
	var spawner_path := "res://scripts/pokemon/pokemon_spawner.gd"
	var game_path := "res://scripts/game.gd"
	assert(FileAccess.file_exists(spawner_path), "Pokemon spawner missing")
	assert(FileAccess.file_exists(game_path), "Game script missing")
	var spawner_text := FileAccess.get_file_as_string(spawner_path)
	assert(spawner_text.contains("select_size"), "Size selection missing")
	assert(spawner_text.contains("select_mutation"), "Mutation selection missing")
	assert(spawner_text.contains("weight_kg"), "Creature weight metadata missing")
	var game_text := FileAccess.get_file_as_string(game_path)
	assert(game_text.contains("_spawn_wild_creature"), "Wild creature spawning missing")
	assert(game_text.contains("BiomeService"), "Biome-aware spawn logic missing")
	print("Step 04 pokemon creation smoke checks passed by static validation.")
	quit()
