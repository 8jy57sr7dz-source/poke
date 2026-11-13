# Prototype design notes

## Current graybox loop

The main scene creates a safe base, treadmill, player, primitive wild-creature visuals, and a pursuing guardian. The current demo intentionally keeps art generic and uses test-only weighted values from JSON. Rare spawn cadence defaults to 300 seconds and is configurable.

## Important online safety boundary

The scripts under `scripts/multiplayer` are not a network backend. Before any online release, move all random rolls, capture claims, currency mutations, speed validation, inventory persistence, and recovery into trusted server code; use database transactions/unique constraints and idempotent request IDs. Persist authoritative state in PostgreSQL through a server runtime such as Nakama. Never use client save files as authority.

## Verification

No Godot runtime was available to run this project during generation. Suggested checks after installing Godot 4.3+:

- `godot --headless --path . --editor --quit`
- `godot --headless --path . --script res://tests/probability_smoke_test.gd`
- Open and run `scenes/main.tscn`, then verify movement, training, pickup, guardian drop, and delivery.
