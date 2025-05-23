# UnitDefinitions.gd
# Centralized stat lookup, separated by team category.
# Place this in res://data/UnitDefinitions.gd

extends Node
class_name UnitDefinitions

# Hero units and their stats
const HEROES := {
	"adventurer": {"max_hp":12, "attack_power":4, "attack_range":1, "ap_per_turn":3},
	"mage":      {"max_hp": 8, "attack_power":5, "attack_range":2, "ap_per_turn":3},
	# add more hero types here
}

# Enemy units and their stats
const ENEMIES := {
	"rat":       {"max_hp":6,  "attack_power":2, "attack_range":1, "ap_per_turn":2},
	"goblin":    {"max_hp":10, "attack_power":3, "attack_range":1, "ap_per_turn":2},
	# add more enemy types here
}

# Neutral or environmental units
const NEUTRALS := {
	# e.g. traps or NPCs
}

# Fetch unit data by type, searching each category in order
static func get_unit_data(unit_type: String) -> Dictionary:
	if HEROES.has(unit_type):
		return HEROES[unit_type]
	elif ENEMIES.has(unit_type):
		return ENEMIES[unit_type]
	elif NEUTRALS.has(unit_type):
		return NEUTRALS[unit_type]
	return {}

# Optionally fetch all types for a given team
static func get_all_by_team(team: String) -> Dictionary:
	match team:
		"player", "ally":
			return HEROES
		"enemy":
			return ENEMIES
		"neutral":
			return NEUTRALS
		_:
			return {}
