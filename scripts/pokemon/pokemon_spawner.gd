extends Node3D

static func create_creature(definition: Dictionary, rng: RandomNumberGenerator, rare: bool = false) -> Node3D:
	var creature := Node3D.new()
	creature.name = str(definition.get("id", "creature"))
	var visual := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.48
	mesh.height = 0.96
	visual.mesh = mesh
	visual.position.y = 0.48
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.55, 0.8, 0.4) if not rare else Color(0.95, 0.8, 0.2)
	visual.material_override = material
	creature.add_child(visual)
	var sizes := ["Tiny", "Small", "Normal", "Large", "Huge", "Giant"]
	var size_weights := PackedFloat32Array([5, 15, 50, 20, 8, 2])
	var size_name: String = sizes[rng.rand_weighted(size_weights)]
	var size_scale := {"Tiny": 0.55, "Small": 0.75, "Normal": 1.0, "Large": 1.25, "Huge": 1.6, "Giant": 2.0}
	creature.scale = Vector3.ONE * float(size_scale[size_name]) * float(definition.get("base_scale", 1.0))
	creature.set_meta("pokemon_record", definition.duplicate(true))
	creature.set_meta("weight_kg", float(definition.get("weight_kg", 1.0)) * float(size_scale[size_name]))
	creature.set_meta("size", size_name)
	creature.set_meta("mutation", "None")
	creature.set_meta("shiny", false)
	creature.set_meta("is_rare_event", rare)
	return creature
