extends Node3D

const CREATURE_POSITIONS := [
	Vector3(-5.0, 0.0, 1.0),
	Vector3(5.5, 0.0, -1.5),
	Vector3(-7.0, 0.0, -3.0),
	Vector3(3.0, 0.0, 6.0),
	Vector3(7.5, 0.0, 4.0),
	Vector3(-2.0, 0.0, -7.0),
	Vector3(0.0, 0.0, 8.0),
	Vector3(-8.0, 0.0, 6.0),
	Vector3(1.0, 0.0, -9.0)
]

func _ready() -> void:
	call_deferred("_add_world_presentation")

func _add_world_presentation() -> void:
	var game := get_tree().get_first_node_in_group("game_manager")
	if game == null:
		return
	_add_guardian_appearance(game)
	_add_landmarks()
	_add_trees_and_bushes()
	_add_rocks_and_flowers()
	_add_path_and_fence()
	_add_all_creatures(game)

func _add_guardian_appearance(game: Node) -> void:
	var guardian := game.get("guardian") as Node3D
	if guardian == null:
		return
	var body_material := _material(Color(0.69, 0.12, 0.16))
	_add_sphere(guardian, Vector3(0.0, 0.9, 0.0), Vector3(1.15, 1.35, 0.95), body_material)
	_add_sphere(guardian, Vector3(0.0, 1.85, 0.0), Vector3(0.8, 0.72, 0.72), body_material)
	_add_cone(guardian, Vector3(-0.45, 2.45, 0.0), Vector3(0.28, 0.8, 0.28), body_material, Vector3(0.0, 0.0, -18.0))
	_add_cone(guardian, Vector3(0.45, 2.45, 0.0), Vector3(0.28, 0.8, 0.28), body_material, Vector3(0.0, 0.0, 18.0))
	_add_sphere(guardian, Vector3(-0.9, 1.05, 0.0), Vector3(0.35, 0.85, 0.38), body_material, Vector3(0.0, 0.0, -20.0))
	_add_sphere(guardian, Vector3(0.9, 1.05, 0.0), Vector3(0.35, 0.85, 0.38), body_material, Vector3(0.0, 0.0, 20.0))
	_add_sphere(guardian, Vector3(0.0, 0.65, 0.0), Vector3(0.22, 0.28, 0.12), _material(Color(1.0, 0.74, 0.18)))
	_add_eyes(guardian, Vector3(0.0, 1.95, -0.55), 0.12)
	var label := Label3D.new()
	label.text = "MEADOW WARDEN"
	label.position.y = 3.05
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 30
	label.outline_size = 8
	guardian.add_child(label)

func _add_all_creatures(game: Node) -> void:
	var definitions: Dictionary = game.get("pokemon_definitions")
	var ids := ["sproutling", "ember_fox", "moon_moth"]
	for index in range(ids.size()):
		var id: String = ids[index]
		if not definitions.has(id):
			continue
		var found: Node3D
		for node in get_tree().get_nodes_in_group("wild_pokemon"):
			if is_instance_valid(node) and str(node.get_meta("pokemon_record", {}).get("id", "")) == id:
				found = node as Node3D
				break
		if found == null:
			game.call("_spawn_creature_by_id", id)
			for node in get_tree().get_nodes_in_group("wild_pokemon"):
				if is_instance_valid(node) and str(node.get_meta("pokemon_record", {}).get("id", "")) == id:
					found = node as Node3D
					break
		if found != null:
			found.position = CREATURE_POSITIONS[index]
		# Fill out the meadow with additional wild creatures from its spawn table.
	for _index in range(6):
		game.call("_spawn_wild_creature")
	var wild := get_tree().get_nodes_in_group("wild_pokemon")
	for index in range(wild.size()):
		var creature := wild[index] as Node3D
		if creature != null and index < CREATURE_POSITIONS.size():
			creature.position = CREATURE_POSITIONS[index]

func _add_landmarks() -> void:
	_add_sign(Vector3(-3.0, 0.0, 2.3), "훈련장\nT 키를 눌러 훈련")
	_add_sign(Vector3(0.0, 0.0, -2.7), "안전 기지\n크리처를 데려오세요")
	_add_sign(Vector3(8.0, 0.0, -1.5), "초원 수호자\n가까이 가지 마세요")
	var pond := MeshInstance3D.new()
	var pond_mesh := CylinderMesh.new()
	pond_mesh.top_radius = 2.0
	pond_mesh.bottom_radius = 2.0
	pond_mesh.height = 0.05
	pond.mesh = pond_mesh
	pond.position = Vector3(-9.0, 0.025, -7.0)
	pond.material_override = _material(Color(0.18, 0.52, 0.72))
	add_child(pond)

func _add_trees_and_bushes() -> void:
	var tree_positions := [
		Vector3(-11.0, 0.0, -8.0), Vector3(-7.0, 0.0, -11.0), Vector3(-1.0, 0.0, -12.0),
		Vector3(5.0, 0.0, -11.0), Vector3(10.0, 0.0, -8.0), Vector3(12.0, 0.0, -2.0),
		Vector3(11.0, 0.0, 6.0), Vector3(6.0, 0.0, 11.0), Vector3(-1.0, 0.0, 12.0),
		Vector3(-8.0, 0.0, 10.0), Vector3(-12.0, 0.0, 4.0), Vector3(-12.0, 0.0, -2.0)
	]
	var leaf_colors := [Color(0.12, 0.42, 0.18), Color(0.18, 0.54, 0.20), Color(0.24, 0.48, 0.15)]
	for index in range(tree_positions.size()):
		var tree := Node3D.new()
		tree.position = tree_positions[index]
		add_child(tree)
		_add_cylinder(tree, Vector3(0.0, 0.85, 0.0), Vector2(0.16, 0.25), 1.7, _material(Color(0.34, 0.19, 0.09)))
		for tier in range(3):
			_add_sphere(tree, Vector3(0.0, 1.75 + float(tier) * 0.48, 0.0), Vector3.ONE * (0.95 - tier * 0.15), _material(leaf_colors[index % leaf_colors.size()]))
	var bush_positions := [Vector3(-5.5, 0.0, 4.0), Vector3(5.5, 0.0, 2.0), Vector3(-6.5, 0.0, -5.0), Vector3(6.0, 0.0, -6.0), Vector3(2.5, 0.0, 8.5)]
	for position in bush_positions:
		_add_sphere(self, position + Vector3(0.0, 0.35, 0.0), Vector3(0.75, 0.7, 0.75), _material(Color(0.1, 0.36, 0.14)))

func _add_rocks_and_flowers() -> void:
	var rocks := [Vector3(-8.0, 0.0, 1.0), Vector3(8.5, 0.0, -4.0), Vector3(4.0, 0.0, 9.0), Vector3(-4.5, 0.0, -8.0), Vector3(9.0, 0.0, 7.0)]
	for index in range(rocks.size()):
		_add_sphere(self, rocks[index] + Vector3(0.0, 0.25, 0.0), Vector3(0.65, 0.45, 0.55), _material(Color(0.38, 0.42, 0.43)), Vector3(8.0 * index, 17.0 * index, 12.0 * index))
	var colors := [Color(1.0, 0.75, 0.15), Color(0.95, 0.3, 0.45), Color(0.95, 0.9, 0.85), Color(0.55, 0.4, 0.95)]
	for index in range(40):
		var angle := TAU * float(index) / 40.0
		var at := Vector3(cos(angle) * 6.8, 0.0, sin(angle) * 6.8)
		_add_cylinder(self, at + Vector3(0.0, 0.2, 0.0), Vector2(0.025, 0.035), 0.4, _material(Color(0.12, 0.45, 0.12)))
		_add_sphere(self, at + Vector3(0.0, 0.43, 0.0), Vector3.ONE * 0.15, _material(colors[index % colors.size()]))

func _add_path_and_fence() -> void:
	var path_material := _material(Color(0.58, 0.43, 0.25))
	for index in range(13):
		var stone := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.55, 0.07, 0.65)
		stone.mesh = mesh
		stone.material_override = path_material
		stone.position = Vector3(-3.2 + index * 0.34, 0.055, 1.55 + sin(float(index) * 0.7) * 0.12)
		add_child(stone)
	var wood := _material(Color(0.42, 0.24, 0.11))
	for index in range(9):
		var post := MeshInstance3D.new()
		var post_mesh := BoxMesh.new()
		post_mesh.size = Vector3(0.12, 0.65, 0.12)
		post.mesh = post_mesh
		post.position = Vector3(-2.8 + index * 0.7, 0.33, -2.2)
		post.material_override = wood
		add_child(post)
	for row in range(2):
		var rail := MeshInstance3D.new()
		var rail_mesh := BoxMesh.new()
		rail_mesh.size = Vector3(5.8, 0.11, 0.1)
		rail.mesh = rail_mesh
		rail.position = Vector3(0.0, 0.22 + row * 0.28, -2.2)
		rail.material_override = wood
		add_child(rail)

func _add_sign(at: Vector3, text: String) -> void:
	_add_cylinder(self, at + Vector3(0.0, 0.7, 0.0), Vector2(0.07, 0.1), 1.4, _material(Color(0.35, 0.2, 0.1)))
	var board := MeshInstance3D.new()
	var board_mesh := BoxMesh.new()
	board_mesh.size = Vector3(1.8, 0.8, 0.12)
	board.mesh = board_mesh
	board.position = at + Vector3(0.0, 1.35, 0.0)
	board.material_override = _material(Color(0.55, 0.32, 0.12))
	add_child(board)
	var label := Label3D.new()
	label.text = text
	label.position = at + Vector3(0.0, 1.35, -0.08)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 24
	label.outline_size = 7
	add_child(label)

func _add_sphere(parent: Node3D, at: Vector3, size: Vector3, material: Material, rotation := Vector3.ZERO) -> MeshInstance3D:
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

func _add_cylinder(parent: Node3D, at: Vector3, radii: Vector2, height: float, material: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radii.x
	mesh.bottom_radius = radii.y
	mesh.height = height
	node.mesh = mesh
	node.position = at
	node.material_override = material
	parent.add_child(node)
	return node

func _add_cone(parent: Node3D, at: Vector3, size: Vector3, material: Material, rotation := Vector3.ZERO) -> MeshInstance3D:
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

func _add_eyes(parent: Node3D, at: Vector3, radius: float) -> void:
	var white := _material(Color.WHITE)
	var dark := _material(Color(0.04, 0.04, 0.06))
	for side in [-1.0, 1.0]:
		_add_sphere(parent, at + Vector3(side * 0.22, 0.0, 0.0), Vector3.ONE * radius * 2.0, white)
		_add_sphere(parent, at + Vector3(side * 0.22, 0.0, -0.09), Vector3.ONE * radius, dark)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	return material
