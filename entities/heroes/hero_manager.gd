# res://entities/HeroManager.gd
extends Node2D

# 🎭 Shared Character scene
const CHARACTER_SCENE = preload("res://entities/unit.tscn")

const TILE_SIZE       = 80
const SPRITE_MAX_SIZE = 80.0

# grid_pos → Character instance
var heroes: Dictionary = {}
var heroes_data = preload("res://scenario/load_heroes.gd").new().generate()


# 🧠 Reference to the portrait row UI
@onready var portrait_row = get_node("../../GUI/BottomPanel/PortraitRow")

func _ready():
	return

# start. spawns heroes and fills portrait UI
func start():
	var visual_data = _load_visual_data(heroes_data)
	spawn_heroes(heroes_data, visual_data)
	_populate_portraits(heroes_data)
	print("Hero Manager: heroes spawned")

# Load both gameplay sprite data and portrait data
func _load_visual_data(data: Array) -> Dictionary:
	var visual_data := {}
	for entry in data:
		var type = entry.type
		var def = HeroDefinitions.get_hero_data(type)
		if def.size() == 0:
			push_warning("No HeroDefinitions for type: %s" % type)
			continue

		# ensure we only load each type once
		if visual_data.has(type):
			continue

		# load gameplay sprite
		var spr_path = def["sprite_path"]
		if not ResourceLoader.exists(spr_path):
			push_warning("Sprite not found: %s" % spr_path)
			continue
		var spr_tex = load(spr_path)

		# load portrait texture
		var port_path = def["portrait_path"]
		if not ResourceLoader.exists(port_path):
			push_warning("Portrait not found: %s" % port_path)
			continue
		var port_tex = load(port_path)

		visual_data[type] = {
			"sprite_texture" : spr_tex,
			"sprite_offset"  : def.get("offset", Vector2.ZERO),
			"portrait_texture": port_tex,
			"portrait_offset" : def.get("portrait_offset", Vector2.ZERO)
		}
	return visual_data

func spawn_heroes(data: Array, visuals: Dictionary) -> void:
	for entry in data:
		var type     = entry.type
		var grid_pos = entry.position

		if not visuals.has(type):
			continue

		# 1) Instance Character.tscn
		var unit = CHARACTER_SCENE.instantiate()
		add_child(unit)

		# 2) Assign logic fields
		unit.unit_type = type
		unit.team      = "player"
		# 1) Pull stats from definitions and inject them
		var def = HeroDefinitions.get_hero_data(type)
		unit.init_from_definition(def)

		# 3) Place on grid
		unit.move_to(grid_pos)

		# 4) Apply gameplay sprite + offset + scale
		var vis = visuals[type]
		var sprite = unit.get_node("Sprite2D") as Sprite2D
		sprite.texture = vis.sprite_texture
		sprite.offset  = vis.sprite_offset

		var ts = vis.sprite_texture.get_size()
		var scl = min(SPRITE_MAX_SIZE/ts.x, SPRITE_MAX_SIZE/ts.y)
		sprite.scale   = Vector2(scl, scl)

		heroes[grid_pos] = unit

func _populate_portraits(data: Array) -> void:
	var types := []
	for h in data:
		types.append(h.type)

	if not portrait_row:
		push_warning("PortraitRow not found")
		return

	# Prepare portrait list using textures & offsets from visuals
	var portrait_defs = []
	for t in types:
		var def = HeroDefinitions.get_hero_data(t)
		if def.size() == 0:
			continue
		portrait_defs.append({
			"texture": load(def["portrait_path"]),
			"offset":  def["portrait_offset"]
		})
	portrait_row.populate(portrait_defs)

# ——— Helpers ———

func get_hero_at(pos: Vector2i) -> Node2D:
	return heroes.get(pos, null)

func move_hero(from: Vector2i, to: Vector2i) -> void:
	if not heroes.has(from):
		push_warning("No hero at %s" % from); return
	if heroes.has(to):
		push_warning("Tile %s occupied" % to); return
	var unit = heroes[from]
	heroes.erase(from)
	heroes[to] = unit
	unit.move_to(to)

func remove_hero(pos: Vector2i) -> void:
	if heroes.has(pos):
		heroes[pos].queue_free()
		heroes.erase(pos)

func get_all_heroes() -> Array:
	return heroes.values()
