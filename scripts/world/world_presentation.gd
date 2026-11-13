extends Node3D

const CREATURE_POSITIONS := [
	Vector3(-5.0, 0.0, 1.0),
	Vector3(5.5, 0.0, -1.5),
	Vector3(-7.0, 0.0, -3.0),
	Vector3(3.0, 0.0, 6.0),
	Vector3(7.5, 0.0, 4.0),
	Vector3(-2.0, 0.0, -7.0),
	Vector3(0.0, 0.0, 8.0)
]

func _ready() -> void:
	call_deferred("_add_world_presentation")

func _add_world_presentation() -> void:
	var game := get_tree().get_first_node_in_group("game_manager")
	if game == null:
		return
	_add_guardian_appearance(game)
	_add_creatures(game)

func _add_guardian_appearance(game: Node) -> void:
	var guardian := game.get("guardian") as Node3D
	if guardian == null:
		return
	var body := MeshInstance3D.new()
	var body_mesh := SphereMesh.new()
	body_mesh.radius = 0.72
	body_mesh.height = 1.55
	body.mesh = body_mesh
	body.position.y = 0.78
	var body_material := StandardMaterial3D.new()
	body_material.albedo_color = Color(0.78, 0.12, 0.16)
	body_material.roughness = 0.65
	body.material_override = body_material
	guardian.add_child(body)
	var label := Label3D.new()
	label.text = "가디언"
	label.position.y = 1.8
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 30
	label.outline_size = 8
	guardian.add_child(label)

func _add_creatures(game: Node) -> void:
	var creatures := get_tree().get_nodes_in_group("wild_pokemon")
	# The game spawns one wild creature during startup; add several more for the meadow.
	for _index in range(5):
		game.call("_spawn_wild_creature")
		creatures = get_tree().get_nodes_in_group("wild_pokemon")
	for index in range(mini(creatures.size(), CREATURE_POSITIONS.size())):
		var creature := creatures[index] as Node3D
		if creature != null:
			creature.position = CREATURE_POSITIONS[index]

func _add_decoration() -> void:
	pass
