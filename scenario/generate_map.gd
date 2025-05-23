# generate_map.gd
extends Node

func generate() -> Dictionary:
	# Later, this could be procedural. For now, return fixed test data.
	return {
"terrain": [
	["G", "G", "G", "W", "W", "G", "G"],
	["G", "R", "G", "W", "G", "G", "G"],
	["G", "G", "G", "G", "G", "R", "G"],
	["G", "G", "W", "W", "G", "G", "G"],
	["G", "G", "G", "G", "G", "G", "W"],
	["W", "G", "G", "R", "G", "G", "G"],
	["G", "G", "G", "G", "W", "W", "G"],
],
		"structures": [
			["", "", "", ""],
			["", "T", "", ""]
		]
	}
