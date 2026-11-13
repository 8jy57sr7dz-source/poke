# Step 12 — Multiplayer/network scaffold

Adds an ENet host/join/leave service and a versioned server-authored state snapshot RPC. The game publishes a compact snapshot (coins, speed, biome, host player position, and carrying flag) and exposes `host_multiplayer(port)`, `join_multiplayer(address, port)`, and `leave_multiplayer()` hooks.

This is a networking foundation only: it does not replicate player nodes, accept client gameplay mutations, or provide matchmaking, authentication, persistence authority, or production anti-cheat. The authoritative game state remains local until those systems are deliberately implemented. Add the same `NetworkService` node path on all peers before using its RPCs.

Static smoke check: `godot --headless --path . --script res://tests/step_12_network_smoke.gd`. A real two-process host/client test is still required; Godot runtime execution was not available during this change.
