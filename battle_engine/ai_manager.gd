extends Node

@onready var bm := get_parent()  # Your BattleManager

var plan_per_enemy: Dictionary = {}

func update_plan():
	plan_per_enemy.clear()
	for enemy in bm.entity_manager.get_all_enemy_units():
		var decision = decide_action(enemy)
		if decision:
			plan_per_enemy[enemy] = decision

func execute_turn():
	var enemies = bm.entity_manager.get_all_enemy_units()
	_execute_enemy_index(0, enemies)

func _execute_enemy_index(index: int, enemies: Array):
	if index >= enemies.size():
		bm.turn_manager.end_enemy_turn()
		return

	var enemy = enemies[index]
	var action = plan_per_enemy.get(enemy, null)
	if action:
		# Bind the callback with index+1 and the enemies array
		var cb = Callable(self, "_on_action_complete").bind(index + 1, enemies)
		process_action(action, cb)
	else:
		_execute_enemy_index(index + 1, enemies)

func _on_action_complete(next_index: int, enemies: Array):
	_execute_enemy_index(next_index, enemies)

func decide_action(enemy) -> Dictionary:
	return {}
	var target = find_closest_player(enemy)
	if target:
		var dist = enemy.position.distance_to(target.position)
		if dist <= enemy.attack_range:
			return {"type":"attack", "source":enemy, "target":target}
		else:
			return {
				"type":"move",
				"source":enemy,
				"target_pos": get_adjacent_toward(enemy.position, target.position)
			}
	return {}

# ———————————————
# Execute a single action, then call `callback.call()` when done
func process_action(action: Dictionary, callback: Callable) -> void:
	match action.type:
		"move":
			bm.entity_manager.move_entity(action.source, action.target_pos)
			await get_tree().create_timer(0.25).timeout
			callback.call()
		"attack":
			var attacker = action.source
			var defender = action.target
			bm.entity_manager.apply_damage(defender, attacker.attack_power)
			await get_tree().create_timer(0.4).timeout
			callback.call()
		_:
			push_warning("AIManager.process_action: unknown action type %s" % action.type)
			callback.call()

# ———————————————
func find_closest_player(enemy) -> Node:
	var best = null
	var best_dist = INF
	for p in bm.entity_manager.get_all_player_units():
		var d = enemy.position.distance_to(p.position)
		if d < best_dist:
			best_dist = d
			best = p
	return best

func get_adjacent_toward(from: Vector2i, to: Vector2i) -> Vector2i:
	return from + (to - from).sign()
