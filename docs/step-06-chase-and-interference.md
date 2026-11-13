# Step 6 — Guardian chase and interference

The guardian now chases a Node3D target while it is within its configured detection range, returns to patrol after losing its target, and has an attack-range threshold. A successful guardian contact drops the carried creature and makes it wild/claimable again.

`game.gd` exposes `apply_interference(attacker)` as an integration hook for an authorized multiplayer collision/hit event. The hook checks that the attacker is a different player in the `players` group, is nearby, and respects a cooldown. It is not a network security boundary; server-side validation is required before connecting it to online play.

Validation in this repository is static only unless the Godot executable is available. Suggested command: `godot --headless --path . --script res://tests/step_06_chase_interference_smoke.gd`.
