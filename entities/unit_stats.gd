# unit_stats.gd
# Attach this script to the Stats node under unit.tscn
# Holds all runtime stats (HP, AP, range, etc.) and handles initialization

extends Node

# Editable properties if you want to tweak in scene, but usually set via data
var max_hp: int
var current_hp: int
var attack_power: int
var attack_range: int
var ap_per_turn: int
var current_ap: int

# Optional: list of active status effects
var statuses: Array = []

# Initialize stats from a data dictionary
func init_from_data(data: Dictionary) -> void:
	max_hp       = data.get("max_hp", 1)
	current_hp   = max_hp
	attack_power = data.get("attack_power", 1)
	attack_range = data.get("attack_range", 1)
	ap_per_turn  = data.get("ap_per_turn", 1)
	current_ap   = ap_per_turn
	statuses.clear()

# Resets AP at start of turn
func reset_ap() -> void:
	current_ap = ap_per_turn
	
# Consumes AP; returns true if successful, false if not enough AP
func consume_ap(amount: int) -> bool:
	if current_ap >= amount:
		current_ap -= amount
		return true
	else:
		print("Not enough AP! Needed:", amount, " Available:", current_ap)
		return false

# Apply a new status effect data (custom structure)
func add_status(status_data: Dictionary) -> void:
	statuses.append(status_data)
	# You could also trigger signals or callbacks here

# Remove a status effect by ID or type
func remove_status(filter_func: Callable) -> void:
	# filter_func should take a status_data and return true if it should be removed
	statuses = statuses.filter(func(s):
		return not filter_func.call(s)
	)

func has_status(filter_func: Callable) -> bool:
	for s in statuses:
		if filter_func.call(s):
			return true
	return false
