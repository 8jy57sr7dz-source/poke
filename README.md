# Pokémon Tycoon — Godot 4 prototype

A standalone, original-asset-free 3D prototype scaffold for the requested creature-collection tycoon. It uses primitive placeholder visuals and configurable JSON data; it does not include Pokémon artwork, models, audio, or other licensed game assets.

## Run

Open this directory in Godot 4.3+ and run `scenes/main.tscn` (or press F6 with the project open). Controls: **WASD** move, **E** pick up a nearby creature / deliver it in the base zone, **T** train on the treadmill zone. The prototype displays current coins, speed, and carried creature in the window title.

## Implemented foundation

- A playable 3D graybox loop: move, train, pick up a generated creature, evade a pursuing guardian, and deliver it to the base.
- Data-driven creature, biome, economy, and probability JSON files.
- Modular scripts for all requested domains: player, pokemon, acquisition, carrying, guardian, biome, probability, economy, base, treadmill, progression, mutation, index, rebirth, multiplayer authority boundary, and save.
- Basic probability validation and a headless smoke-test script.

## Scope and limitations

This is a **prototype foundation**, not a completed production game. No Godot executable was available in the authoring environment, so runtime/editor tests have **not** been run. In particular, Nakama/PostgreSQL integration, authoritative multi-instance persistence, reconnect-safe transactional inventory, anti-cheat enforcement, mobile UX/performance, production guardian/navigation AI, full UI, and 100-player load testing remain future work. `scripts/multiplayer/session_authority.gd` is an interface/demo boundary only; local client-side code is not secure authority for an online economy. Do not deploy this prototype as an online service.

Probability values in `data/probabilities.json` are explicitly marked as **test defaults**, not official source-game odds. The original source-game odds are not asserted or reproduced.

## Structure

- `assets/` — reserved for original/appropriately licensed assets.
- `data/` — JSON configuration.
- `scenes/` — Godot scenes.
- `scripts/` — separated gameplay systems.
- `server/` — reserved for a future Nakama server implementation.
- `tests/` — manual/headless smoke-test entry point.
- `docs/` — implementation notes.

No egg or hatching mechanics and no base-invasion/theft mechanic are included.
