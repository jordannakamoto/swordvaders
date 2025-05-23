extends Node
class_name EnemyDefinitions

# Static map of enemy types to their visual data
static var DATA: Dictionary = {
	"rat": {
		"sprite_path": "res://bestiary/starter/rat/rat.png",
		"offset": Vector2(0, 6),
		"max_hp":          12,
		"current_hp":      12,
		"attack_power":    4,
		"attack_range":    1,
		"ap_per_turn":     3,
	},
	# Add additional enemy types here:
	# "goblin": {"sprite_path": "res://bestiary/starter/goblin/goblin.png", "offset": Vector2(0, 4)}
}

# Fetch the data dictionary for a given enemy type
static func get_enemy_data(type: String) -> Dictionary:
	return DATA.get(type, {})

# Optionally list all known enemy types
static func get_all_types() -> Array:
	return DATA.keys()
