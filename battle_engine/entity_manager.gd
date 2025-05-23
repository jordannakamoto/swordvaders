extends Node

var player_units: Array = []
var enemy_units: Array = []

func initialize_units():
	var heroes_node = get_node("../../Entities/Heroes")
	var enemies_node = get_node("../../Entities/Enemies")

	player_units = heroes_node.get_children()
	enemy_units = enemies_node.get_children()

func get_all_units() -> Array:
	return player_units + enemy_units
func get_all_player_units() -> Array:
	return player_units
func get_all_enemy_units() -> Array:
	return enemy_units
	
func get_hero_by_name(name: String) -> Node:
	for hero in player_units:
		if hero.name == name:
			return hero
	return null

# Move with built-in entity method
func move_entity(entity: Node2D, target_pos: Vector2i) -> void:
	if entity.has_method("move_to"):
		entity.move_to(target_pos)
	else:
		push_warning("Entity has no move_to(): %s" % entity)

func apply_damage(target: Node, amount: int) -> void:
	if target.has_method("apply_damage"):
		target.apply_damage(amount)
	else:
		push_warning("Missing apply_damage() on: %s" % target)

func apply_status(target: Node, status) -> void:
	if target.has_method("apply_status"):
		target.apply_status(status)
	else:
		push_warning("Missing apply_status() on: %s" % target)
		
func get_unit_at(pos: Vector2i) -> Node:
	for unit in get_all_units():
		if unit.has_method("get_map_position") and unit.get_map_position() == pos:
			return unit
	return null
