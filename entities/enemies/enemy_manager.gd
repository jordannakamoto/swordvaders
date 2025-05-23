extends Node2D

# 🎭 Now use the shared Unit scene
const CHARACTER_SCENE = preload("res://entities/unit.tscn")

const TILE_SIZE = 80
const SPRITE_MAX_SIZE = 64.0

# grid_pos → character instance
var enemies: Dictionary = {}
var enemies_data = preload("res://scenario/generate_enemies.gd").new().generate()


func _ready():
	return
	
func start():
	var visual_data = _load_visual_data(enemies_data)
	spawn_enemies(enemies_data, visual_data)
	print("Enemy Manager: enemies spawned")

func _load_visual_data(data: Array) -> Dictionary:
	var visual_data := {}
	for entry in data:
		var type = entry.type
		var info = EnemyDefinitions.get_enemy_data(type)
		if info.size() == 0:
			push_warning("No data for enemy type: %s" % type)
			continue

		var path = info.sprite_path
		if ResourceLoader.exists(path):
			visual_data[type] = {
			"texture": load(path),
			"offset": info.offset
			}
		else:
			push_warning("Sprite not found at: %s" % path)
	return visual_data

func spawn_enemies(data: Array, visuals: Dictionary) -> void:
	for entry in data:
		var grid_pos: Vector2i = entry.position
		var type: String = entry.type

		if not visuals.has(type):
			continue

		# 1) Instance the shared Character scene
		var unit = CHARACTER_SCENE.instantiate()
		add_child(unit)

		# 2) Configure its logic data
		unit.unit_type = type
		unit.team = "enemy"
		# Initialize stats via the definitions file
		var def = EnemyDefinitions.get_enemy_data(type)
		unit.init_from_definition(def)
		
		# 3) Position on the grid
		unit.move_to(grid_pos)

		# 4) Apply the correct sprite + offset + scale
		var sprite = unit.get_node("Sprite2D") as Sprite2D
		var vis = visuals[type]
		sprite.texture = vis.texture
		sprite.offset = vis.offset

		var tex_size = vis.texture.get_size()
		var scale = min(SPRITE_MAX_SIZE / tex_size.x, SPRITE_MAX_SIZE / tex_size.y)
		sprite.scale = Vector2(scale, scale)

		# 5) Register in our lookup
		enemies[grid_pos] = unit

# Helpers

func get_enemy_at(pos: Vector2i) -> Node2D:
	return enemies.get(pos, null)

func remove_enemy(pos: Vector2i) -> void:
	if enemies.has(pos):
		enemies[pos].queue_free()
		enemies.erase(pos)

func move_enemy(from: Vector2i, to: Vector2i) -> void:
	if not enemies.has(from):
		push_warning("No enemy to move from %s" % from)
		return
	if enemies.has(to):
		push_warning("Target tile %s occupied" % to)
		return
	var unit = enemies[from]
	enemies.erase(from)
	enemies[to] = unit
	unit.move_to(to)

func get_all_enemies() -> Array:
	return enemies.values()
