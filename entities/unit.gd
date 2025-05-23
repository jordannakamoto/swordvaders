# Shared character scene handling both player and enemy units.
# Supports stats, movement, damage, status effects, and team alignment.

extends Node2D

# CONFIGURATION
@export var unit_type: String = ""            # e.g., "adventurer", "rat"
@export var team: String = "neutral"           # one of: "player", "enemy", "ally", "neutral"

# COMPONENT REFERENCES
@onready var stats                 = $Stats         # Node with Stats.gd
@onready var sprite                = $Sprite2D      # Visual sprite
@onready var health_bar            = $UI/HealthBar 
@onready var status_container      = $UI/StatusEffects  # Container for status icons
@onready var selection_highlight   = $UI/SelectionHighlight

const TILE_SIZE = 80.0

var grid_pos: Vector2i = Vector2i.ZERO

func _ready():
	# Hide selection by default
	if selection_highlight:
		selection_highlight.visible = false

func init_from_definition(data: Dictionary) -> void:
	stats.init_from_data(data)
	_setup_health_bar_textures()
	_update_health_bar()

# call this early in _ready()
func _setup_health_bar_textures() -> void:
	# make sure we have a TextureProgress
	var hp = health_bar as TextureProgressBar
	if not hp:
		push_warning("Expected a TextureProgress at %s" % health_bar)
		return

	# 2) Team-based fill
	var fill_path := ""
	match team:
		"enemy":
			fill_path = "res://entities/unit/enemy_hp.png"
		"player":
			fill_path = "res://entities/unit/player_hp.png"
		"ally":
			fill_path = "res://entities/unit/ally_hp.png"
		_:
			fill_path = "res://entities/unit/neutral_hp.png"

	if ResourceLoader.exists(fill_path):
		hp.texture_progress = load(fill_path) as Texture2D
	else:
		push_warning("Health-fill texture missing at %s" % fill_path)

func get_map_position() -> Vector2i:
	return grid_pos
	
# Turn-based APIs
func reset_ap():
	stats.reset_ap()
	_update_ap_ui()
 
func move_to(pos: Vector2i) -> void:
	grid_pos = pos
	position = Vector2(pos) * TILE_SIZE + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)

func apply_damage(amount: int) -> void:
	stats.current_hp = max(stats.current_hp - amount, 0)
	_update_health_bar()
	if stats.current_hp <= 0:
		die()

func apply_status(status_data) -> void:
	# Add icon under status_container
	var tex = load(status_data.icon_path) as Texture
	var icon = TextureRect.new()
	icon.texture = tex
	status_container.add_child(icon)
	stats.add_status(status_data)

func die() -> void:
	# Play death animation or effect then remove
	queue_free()

# SELECTION & HIGHLIGHT
func show_selection(enabled: bool) -> void:
	if selection_highlight:
		selection_highlight.visible = enabled

# UI UPDATES
func _update_health_bar():
	if health_bar:
		health_bar.max_value = stats.max_hp
		health_bar.value = stats.current_hp

func _update_ap_ui():
	# Optionally implement AP bar update under portrait UI
	pass

# ACCESSORS
func is_alive() -> bool:
	return stats.current_hp > 0

func get_team() -> String:
	return team

func get_stats():
	return stats

# DEBUG
func _debug_print():
	print("[Character] %s (Team: %s) HP: %d/%d AP: %d" % [name, team, stats.current_hp, stats.max_hp, stats.current_ap])
