extends Node

signal status_changed(status: String)
signal snapshot_received(snapshot: Dictionary)
signal peer_joined(peer_id: int)
signal peer_left(peer_id: int)

const PROTOCOL_VERSION := 1
const DEFAULT_PORT := 24567
const MAX_PEERS := 16

var status := "Offline"
var _last_snapshot: Dictionary = {}

func _ready() -> void:
	if not multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.connect(_on_peer_connected)
	if not multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if not multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.connect(_on_connected_to_server)
	if not multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.connect(_on_connection_failed)
	if not multiplayer.server_disconnected.is_connected(_on_server_disconnected):
		multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game(port: int = DEFAULT_PORT, max_clients: int = MAX_PEERS) -> Error:
	if port < 1 or port > 65535 or max_clients < 1 or max_clients > MAX_PEERS:
		return ERR_INVALID_PARAMETER
	close_session()
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_server(port, max_clients)
	if result != OK:
		_set_status("Host failed (%s)" % error_string(result))
		return result
	multiplayer.multiplayer_peer = peer
	_set_status("Hosting on port %d" % port)
	return OK

func join_game(address: String, port: int = DEFAULT_PORT) -> Error:
	var trimmed_address := address.strip_edges()
	if trimmed_address.is_empty() or port < 1 or port > 65535:
		return ERR_INVALID_PARAMETER
	close_session()
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_client(trimmed_address, port)
	if result != OK:
		_set_status("Join failed (%s)" % error_string(result))
		return result
	multiplayer.multiplayer_peer = peer
	_set_status("Connecting to %s:%d" % [trimmed_address, port])
	return OK

func close_session() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	_last_snapshot.clear()
	_set_status("Offline")

func is_host() -> bool:
	return multiplayer.multiplayer_peer != null and multiplayer.is_server()

func publish_snapshot(snapshot: Dictionary) -> void:
	if not is_host():
		return
	var payload := snapshot.duplicate(true)
	payload["protocol_version"] = PROTOCOL_VERSION
	_last_snapshot = payload
	rpc("_receive_snapshot", payload)

@rpc("any_peer", "call_remote", "reliable")
func _request_snapshot() -> void:
	if not is_host() or _last_snapshot.is_empty():
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id > 1:
		rpc_id(sender_id, "_receive_snapshot", _last_snapshot)

@rpc("authority", "call_remote", "reliable")
func _receive_snapshot(snapshot: Dictionary) -> void:
	if not _is_valid_snapshot(snapshot):
		return
	_last_snapshot = snapshot.duplicate(true)
	snapshot_received.emit(_last_snapshot.duplicate(true))

func _is_valid_snapshot(snapshot: Dictionary) -> bool:
	if int(snapshot.get("protocol_version", -1)) != PROTOCOL_VERSION:
		return false
	if not snapshot.has("coins") or not snapshot.has("speed") or not snapshot.has("player_position"):
		return false
	return snapshot.get("player_position") is Vector3

func _on_peer_connected(peer_id: int) -> void:
	peer_joined.emit(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	peer_left.emit(peer_id)

func _on_connected_to_server() -> void:
	_set_status("Connected to host")
	rpc_id(1, "_request_snapshot")

func _on_connection_failed() -> void:
	close_session()
	_set_status("Connection failed")

func _on_server_disconnected() -> void:
	close_session()
	_set_status("Host disconnected")

func _set_status(value: String) -> void:
	status = value
	status_changed.emit(status)
