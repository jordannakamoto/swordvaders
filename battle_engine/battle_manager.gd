extends Node

@onready var turn_manager = $TurnManager
@onready var card_manager = $CardManager
@onready var effect_processor = $EffectProcessor
@onready var entity_manager = $EntityManager
@onready var ai_manager = $AIManager
@onready var enemy_manager = get_node("../Entities/Enemies")
@onready var hero_manager = get_node("../Entities/Heroes")


func _ready():
	start_battle()

func start_battle():
	# Initialize entities and begin player turn
	enemy_manager.start()
	hero_manager.start()
	entity_manager.initialize_units()
	turn_manager.start_player_turn()
	print("battle started")

func end_battle(victory: bool):
	# TODO: cleanup, show end screen
	print("Battle ended. Victory: %s" % victory)
