extends SceneTree

func _initialize() -> void:
	var network_path := "res://scripts/network/network_service.gd"
	var game_path := "res://scripts/game.gd"
	assert(FileAccess.file_exists(network_path), "Network service missing")
	assert(FileAccess.file_exists(game_path), "Game integration missing")
	var network_text := FileAccess.get_file_as_string(network_path)
	assert(network_text.contains("host_game"), "Host API missing")
	assert(network_text.contains("join_game"), "Join API missing")
	assert(network_text.contains("_receive_snapshot"), "Snapshot RPC missing")
	assert(network_text.contains("protocol_version"), "Snapshot version check missing")
	var game_text := FileAccess.get_file_as_string(game_path)
	assert(game_text.contains("host_multiplayer"), "Game host hook missing")
	assert(game_text.contains("join_multiplayer"), "Game join hook missing")
	assert(game_text.contains("_publish_network_snapshot"), "Snapshot publisher missing")
	print("Step 12 multiplayer scaffold static checks passed.")
	quit()
