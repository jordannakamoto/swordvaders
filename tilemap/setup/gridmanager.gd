extends Node2D

@onready var terrain_layer = $Terrain
@onready var structure_layer = $Structures
@onready var highlight_layer := $Highlights
@onready var cursor_layer := $Cursors
@onready var entity_manager = get_node("../BattleManager/EntityManager")

@export var tile_size := 80  # Match your visual tile size

# 🔧 CONFIGURABLE CONSTANTS
const TILE_SOURCE_SIZE = 300.0  # Native tile pixel size from tileset
const TARGET_TILE_SIZE = 80.0   # Desired visual size on screen
const VERTICAL_OFFSET = -560  # Offset to lift map above UI

var last_cursor_pos: Vector2i = Vector2i(-1, -1)
const CURSOR_TILE_INDEX = 0  # The tile index used for the cursor
const CURSOR_SOURCE_ID = 0   # The source ID from your cursor TileSet

# 🗺️ Tile type definitions
const TERRAIN_TILES = { "G": 0, "W": 1, "R": 2 }
const STRUCTURE_TILES = { "T": 0 }

# 💾 Atlas source IDs
const TERRAIN_SOURCE_ID = 1
const STRUCTURE_SOURCE_ID = 2

const HIGHLIGHT_TILE_INDEX := 0  # Assuming one tile (e.g. blue overlay) in your tileset
const HIGHLIGHT_SOURCE_ID := 0   # Set based on your TileSet source ID for highlights

func _ready():
	var scale_factor = TARGET_TILE_SIZE / TILE_SOURCE_SIZE
	
	# Apply scale to both layers
	terrain_layer.scale = Vector2(scale_factor, scale_factor)
	structure_layer.scale = Vector2(scale_factor, scale_factor)
	highlight_layer.scale = Vector2(scale_factor, scale_factor)
	cursor_layer.scale = Vector2(scale_factor, scale_factor)
	
	# Load and render map
	var map_data = load("res://scenario/generate_map.gd").new().generate()
	render_map(map_data)

	# Center tilemap after rendering
	var map_width = map_data["terrain"][0].size()
	var map_height = map_data["terrain"].size()
	center_tilemap(map_width, map_height, scale_factor)

func center_tilemap(map_width: int, map_height: int, scale: float):
	var viewport_size = get_viewport().get_visible_rect().size

	var map_pixel_width = map_width * TILE_SOURCE_SIZE * scale
	var map_pixel_height = map_height * TILE_SOURCE_SIZE * scale

	var offset_x = (viewport_size.x - map_pixel_width) * 0.5
	var offset_y = VERTICAL_OFFSET + (viewport_size.y - map_pixel_height - VERTICAL_OFFSET) * 0.5

	terrain_layer.position = Vector2(offset_x, offset_y)
	structure_layer.position = Vector2(offset_x, offset_y)
	highlight_layer.position = Vector2(offset_x, offset_y)
	cursor_layer.position = Vector2(offset_x, offset_y)

func render_map(map_data: Dictionary) -> void:
	var terrain = map_data["terrain"]
	# var structures = map_data["structures"]

	for y in terrain.size():
		for x in terrain[y].size():
			var pos = Vector2i(x, y)
			var t_code = terrain[y][x]
			# var s_code = structures[y][x]

			if TERRAIN_TILES.has(t_code):
				var terrain_tile = TERRAIN_TILES[t_code]
				terrain_layer.set_cell(pos, TERRAIN_SOURCE_ID, Vector2i(terrain_tile, 0))
			# if STRUCTURE_TILES.has(s_code):
			# 	var struct_tile = STRUCTURE_TILES[s_code]
			# 	structure_layer.set_cell(pos, STRUCTURE_SOURCE_ID, Vector2i(struct_tile, 0))

################################################################################################

func get_tiles_in_range(origin: Vector2i, max_range: int) -> Array[Vector2i]:
	var visited := {}
	var result: Array[Vector2i] = []
	var queue := [ { "pos": origin, "dist": 0 } ]

	while queue.size() > 0:
		var current = queue.pop_front()
		var pos: Vector2i = current["pos"]
		var dist: int = current["dist"]
		# Clamp to map bounds
		if pos.x < 0 or pos.y < 0 or pos.x >= 7 or pos.y >= 8:
			continue

		if visited.has(pos) or dist > max_range:
			continue

		visited[pos] = true
		result.append(pos)

		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			queue.append({ "pos": pos + dir, "dist": dist + 1 })
	return result
	
func get_tiles_in_range_move(origin: Vector2i, max_range: int, requester_team: String) -> Array[Vector2i]:
	var visited := {}
	var result: Array[Vector2i] = []
	var queue := [ { "pos": origin, "dist": 0 } ]

	while queue.size() > 0:
		var current = queue.pop_front()
		var pos: Vector2i = current["pos"]
		var dist: int = current["dist"]

		# Bounds check
		if pos.x < 0 or pos.y < 0 or pos.x >= 7 or pos.y >= 7:
			continue

		# Already visited or too far
		if visited.has(pos) or dist > max_range:
			continue

		visited[pos] = true

		var blocker = entity_manager.get_unit_at(pos)

		# Blockers:
		if blocker:
			if blocker.get_team() == requester_team:
				# Can pass through allies but not stop on them
				if dist < max_range:
					for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
						queue.append({ "pos": pos + dir, "dist": dist + 1 })
				continue
			else:
				# Cannot move through or onto enemies
				continue

		# Valid move destination (unoccupied tile)
		result.append(pos)

		# Enqueue neighbors only if not blocked
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			queue.append({ "pos": pos + dir, "dist": dist + 1 })

	return result
	
func highlight_tiles(tiles: Array[Vector2i], type: String = "move") -> void:
	highlight_layer.clear()
	# Optionally support different highlight styles by type
	var tile_index := 0
	match type:
		"move":
			tile_index = 0  # blue
		"attack":
			tile_index = 1  # red
		"select":
			tile_index = 2  # greens

	for tile in tiles:
		highlight_layer.set_cell(tile, HIGHLIGHT_SOURCE_ID, Vector2i(tile_index,0))

func clear_highlights() -> void:
	highlight_layer.clear()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		update_cursor()
		
func update_cursor():
	# Convert from screen coordinates to tilemap coordinates
	var mouse_pos = get_viewport().get_mouse_position()
	var local_mouse = terrain_layer.to_local(mouse_pos)
	var tile_pos = terrain_layer.local_to_map(local_mouse)

	# Clamp to map bounds (7 columns x 8 rows)
	if tile_pos.x < 0 or tile_pos.y < 0 or tile_pos.x >= 7 or tile_pos.y >= 7:
		cursor_layer.set_cell(last_cursor_pos, CURSOR_SOURCE_ID, Vector2i(-1, -1))  # Clear previous
		return

	# Skip if tile hasn't changed
	if tile_pos == last_cursor_pos:
		return

	# Clear previous cursor
	if last_cursor_pos != Vector2i(-1, -1):
		cursor_layer.set_cell(last_cursor_pos, CURSOR_SOURCE_ID, Vector2i(-1, -1))  # Clear previous

	# Set new cursor tile
	cursor_layer.set_cell(tile_pos, CURSOR_SOURCE_ID, Vector2i(CURSOR_TILE_INDEX, 0))
	last_cursor_pos = tile_pos
