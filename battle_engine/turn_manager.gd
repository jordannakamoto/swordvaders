# TurnManager.gd
extends Node

# Simply grab the parent node (BattleManager)
@onready var bm := get_parent()

var is_player_turn := true

func start_player_turn():
	is_player_turn = true
	print(">> Player Turn Start <<")
	# Reset AP and draw
	for hero in bm.entity_manager.get_all_player_units():
		hero.reset_ap()
	bm.card_manager.start_player_phase()
	bm.ai_manager.update_plan()

func end_player_turn():
	print("-- Player Turn End --")
	bm.ai_manager.update_plan()
	start_enemy_turn()

func start_enemy_turn():
	is_player_turn = false
	print(">> Enemy Turn Start <<")
	bm.ai_manager.execute_turn()

func end_enemy_turn():
	print("-- Enemy Turn End --")
	start_player_turn()
