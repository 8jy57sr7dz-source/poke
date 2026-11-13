extends RefCounted

static func create_creature(definition: Dictionary, rng: RandomNumberGenerator, rare: bool = false, biome_id: String = "meadow", probability_config: Dictionary = {}) -> Node3D:
	var creature := Node3D.new()
	var pokemon_id := str(definition.get("id", "creature"))
	creature.name = pokemon_id
	var body_color := _body_color(pokemon_id, rare)
	var body_material := _material(body_color)
	var dark_material := _material(body_color.darkened(0.28))
	var light_material := _material(body_color.lightened(0.3))

	match pokemon_id:
		"sproutling":
			_add_sphere(creature, Vector3(0.0, 0.48, 0.0), Vector3(0.82, 0.78, 0.72), body_material)
			_add_sphere(creature, Vector3(0.0, 0.96, -0.02), Vector3(0.55, 0.5, 0.52), light_material)
			_add_cone(creature, Vector3(-0.2, 1.34, 0.0), Vector3(0.3, 0.55, 0.25), dark_material, Vector3(0.0, 0.0, -22.0))
			_add_cone(creature, Vector3(0.2, 1.35, 0.0), Vector3(0.3, 0.62, 0.25), dark_material, Vector3(0.0, 0.0, 20.0))
			_add_sphere(creature, Vector3(0.0, 1.52, 0.0), Vector3(0.3, 0.22, 0.27), _material(Color(0.95, 0.78, 0.18)))
		"ember_fox":
			_add_sphere(creature, Vector3(0.0, 0.48, 0.0), Vector3(0.95, 0.72, 0.62), body_material)
			_add_sphere(creature, Vector3(0.0, 0.98, -0.1), Vector3(0.62, 0.62, 0.58), body_material)
			_add_cone(creature, Vector3(-0.35, 1.48, -0.04), Vector3(0.32, 0.85, 0.3), dark_material, Vector3(0.0, 0.0, -12.0))
			_add_cone(creature, Vector3(0.35, 1.48, -0.04), Vector3(0.32, 0.85, 0.3), dark_material, Vector3(0.0, 0.0, 12.0))
			_add_sphere(creature, Vector3(0.0, 0.82, -0.59), Vector3(0.58, 0.28, 0.2), light_material)
			_add_sphere(creature, Vector3(0.82, 0.48, 0.42), Vector3(0.35, 0.75, 0.35), light_material, Vector3(0.0, 0.0, -48.0))
			_add_sphere(creature, Vector3(0.82, 0.83, 0.42), Vector3(0.4, 0.28, 0.36), ColorMaterial.new())
		"moon_moth":
			_add_sphere(creature, Vector3(0.0, 0.55, 0.0), Vector3(0.48, 0.95, 0.5), body_material)
			_add_sphere(creature, Vector3(0.0, 1.13, -0.03), Vector3(0.62, 0.55, 0.56), light_material)
			_add_sphere(creature, Vector3(-0.72, 0.88, 0.0), Vector3(0.95, 0.42, 0.12), dark_material, Vector3(0.0, 0.0, -22.0))
			_add_sphere(creature, Vector3(0.72, 0.88, 0.0), Vector3(0.95, 0.42, 0.12), dark_material, Vector3(0.0, 0.0, 22.0))
			_add_sphere(creature, Vector3(-0.7, 0.9, -0.08), Vector3(0.34, 0.22, 0.1), light_material)
			_add_sphere(creature, Vector3(0.7, 0.9, -0.08), Vector3(0.34, 0.22, 0.1), light_material)
			_add_cone(creature, Vector3(-0.22, 1.62, 0.0), Vector3(0.12, 0.55, 0.12), light_material, Vector3(0.0, 0.0, -25.0))
			_add_cone(creature, Vector3(0.22, 1.62, 0.0), Vector3(0.12, 0.55, 0.12), light_material, Vector3(0.0, 0.0, 25.0))
		_:
			_add_sphere(creature, Vector3(0.0, 0.55, 0.0), Vector3.ONE, body_material)

	_add_eyes(creature, Vector3(0.0, 1.0, -0.48), 0.09)
	var name_label := Label3D.new()
	name_label.text = str(definition.get("name", pokemon_id))
	name_label.position.y = 1.95
	name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	name_label.font_size = 26
	name_label.outline_size = 7
	creature.add_child(name_label)

	var tables: Dictionary = probability_config.get("tables", {})
	var size_data := _weighted_entry(tables.get("size", []), rng, {"id": "Normal", "weight": 1})
	var size_name := str(size_data.get("id", "Normal"))
	var size_scale := _default_size_scale(size_name) * float(definition.get("base_scale", 1.0))
	creature.scale = Vector3.ONE * size_scale
	var mutation_name := "None"
	if rare:
		var mutation_data := _weighted_entry(tables.get("mutation", []), rng, {"id": "None", "weight": 1})
		mutation_name = str(mutation_data.get("id", "None"))
	var shiny_data := _weighted_entry(tables.get("shiny", []), rng, {"id": "false", "weight": 1})
	var shiny := str(shiny_data.get("id", "false")).to_lower() == "true"
	var record: Dictionary = definition.duplicate(true)
	record["biome_id"] = biome_id
	record["size"] = size_name
	record["mutation"] = mutation_name
	record["shiny"] = shiny
	creature.set_meta("pokemon_record", record)
	creature.set_meta("weight_kg", float(definition.get("weight_kg", 1.0)) * size_scale)
	creature.set_meta("carry_speed_factor", float(definition.get("carry_speed_factor", 1.0)))
	creature.set_meta("size", size_name)
	creature.set_meta("mutation", mutation_name)
	creature.set_meta("shiny", shiny)
	creature.set_meta("is_rare_event", rare)
	creature.set_meta("biome_id", biome_id)
	creature.set_meta("base_income_per_second", float(definition.get("income_per_second", 1.0)))
	return creature

static func _body_color(pokemon_id: String, rare: bool) -> Color:
	if rare:
		return Color(1.0, 0.68, 0.12)
	match pokemon_id:
		"sproutling": return Color(0.25, 0.68, 0.28)
		"ember_fox": return Color(0.92, 0.35, 0.12)
		"moon_moth": return Color(0.46, 0.35, 0.82)
		_: return Color(0.4, 0.75, 0.4)

static func _default_size_scale(size_name: String) -> float:
	match size_name:
		"Tiny": return 0.55
		"Small": return 0.75
		"Large": return 1.25
		"Huge": return 1.6
		"Giant": return 2.0
		_: return 1.0

static func _weighted_entry(entries: Variant, rng: RandomNumberGenerator, fallback: Dictionary) -> Dictionary:
	if not entries is Array:
		return fallback
	var total_weight := 0.0
	for value in entries:
		if value is Dictionary:
			total_weight += maxf(float(value.get("weight", 0.0)), 0.0)
	if total_weight <= 0.0:
		return fallback
	var roll := rng.randf_range(0.0, total_weight)
	var accumulated := 0.0
	for value in entries:
		if not value is Dictionary:
			continue
		var entry: Dictionary = value
		accumulated += maxf(float(entry.get("weight", 0.0)), 0.0)
		if roll <= accumulated:
			return entry
	return fallback

static func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.7
	return material

static func _add_sphere(parent: Node3D, at: Vector3, size: Vector3, material: Material, rotation := Vector3.ZERO) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	node.mesh = mesh
	node.position = at
	node.scale = size
	node.rotation_degrees = rotation
	node.material_override = material
	parent.add_child(node)
	return node

static func _add_cone(parent: Node3D, at: Vector3, size: Vector3, material: Material, rotation := Vector3.ZERO) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = 0.5
	mesh.height = 1.0
	node.mesh = mesh
	node.position = at
	node.scale = size
	node.rotation_degrees = rotation
	node.material_override = material
	parent.add_child(node)
	return node

static func _add_eyes(parent: Node3D, at: Vector3, radius: float) -> void:
	var white := _material(Color.WHITE)
	var pupil := _material(Color(0.04, 0.04, 0.06))
	for side in [-1.0, 1.0]:
		_add_sphere(parent, at + Vector3(side * 0.18, 0.0, 0.0), Vector3.ONE * radius * 2.0, white)
		_add_sphere(parent, at + Vector3(side * 0.18, 0.0, -0.06), Vector3.ONE * radius, pupil)
