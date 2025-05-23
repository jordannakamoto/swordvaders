# res://data/HeroDefinitions.gd
extends Node
class_name HeroDefinitions

static var DATA := {
	"adventurer": {
		"sprite_path":     "res://heroes/starter/adventurer.png",
		"offset":          Vector2(0, -20),
		"portrait_path":   "res://heroes/starter/adventurer_art.png",
		"portrait_offset": Vector2(0, -330),
		"max_hp":          100,
		"current_hp":      100,
		"attack_power":    4,
		"attack_range":    1,
		"ap_per_turn":     4,
	},
	"squire": {
		"sprite_path":     "res://heroes/starter/squire.png",
		"offset":          Vector2(0, -40),
		"portrait_path":   "res://heroes/starter/squire_art.png",
		"portrait_offset": Vector2(0, -265),
		"max_hp":          100,
		"current_hp":      100,
		"attack_power":    4,
		"attack_range":    1,
		"ap_per_turn":     4,
	},
	"apprentice": {
		"sprite_path":     "res://heroes/starter/apprentice.png",
		"offset":          Vector2(0, -30),
		"portrait_path":   "res://heroes/starter/apprentice_art.png",
		"portrait_offset": Vector2(0, -380),
		"max_hp":          100,
		"current_hp":      100,
		"attack_power":    4,
		"attack_range":    1,
		"ap_per_turn":     4,
	},
	# …etc…
}

static func get_hero_data(type: String) -> Dictionary:
	return DATA.get(type, {})
