extends Node

@onready var bm := get_parent()
@onready var entity_manager := bm.get_node("EntityManager")
@onready var hand_row := get_node("../../GUI/BottomPanel/HandRow")

var hands := {}         # index -> Array of cards in hand
var decks := {}         # index -> full deck (for resetting or debug)
var draw_piles := {}    # index -> current draw pile
var discard_piles := {} # index -> discarded cards

signal hand_updated(hands_map: Dictionary)

func _ready():
	hand_row.connect("card_used", Callable(bm.get_node("CardManager"), "_on_card_used"))
	prepare_dummy_decks()

func prepare_dummy_decks():
	var dummy_data := {
		0: [
			{ "id": 1000, "type": "move",        "cost": 1 },
			{ "id": 1001, "type": "attack",      "cost": 1 },
			{ "id": 1002, "type": "heal",        "cost": 1 },
			{ "id": 1003, "type": "move",        "cost": 1 },
			{ "id": 1004, "type": "big attack",  "cost": 2 }
		],
		1: [
			{ "id": 2000, "type": "attack",      "cost": 1 },
			{ "id": 2001, "type": "attack",      "cost": 1 },
			{ "id": 2002, "type": "move",        "cost": 1 },
			{ "id": 2003, "type": "heal",        "cost": 1 }
		],
		2: [
			{ "id": 3000, "type": "move",        "cost": 1 },
			{ "id": 3001, "type": "heal",        "cost": 1 },
			{ "id": 3002, "type": "super attack","cost": 3 },
			{ "id": 3003, "type": "move",        "cost": 1 }
		]
	}

	for i in dummy_data.keys():
		var full_deck = dummy_data[i].duplicate(true)
		decks[i] = full_deck
		draw_piles[i] = full_deck.duplicate(true)
		discard_piles[i] = []
		hands[i] = []

	shuffle_all_draw_piles()

func shuffle_all_draw_piles():
	for i in draw_piles.keys():
		draw_piles[i].shuffle()

func draw_phase():
	var heroes = entity_manager.get_all_player_units()
	for i in range(heroes.size()):
		hands[i] = []

		for j in range(4):
			if draw_piles[i].is_empty():
				refill_draw_pile_from_discard(i)
			if not draw_piles[i].is_empty():
				hands[i].append(draw_piles[i].pop_back())

		print("Drew %d cards for hero index %d" % [hands[i].size(), i])
		
	emit_hand_state()

func refill_draw_pile_from_discard(index: int):
	draw_piles[index] = discard_piles[index].duplicate(true)
	discard_piles[index] = []
	draw_piles[index].shuffle()
	print("Shuffled discard into draw pile for hero", index)

func emit_hand_state():
	hand_row.populate(hands)

func get_hand(index: int) -> Array:
	return hands.get(index, [])

func remove_card(index: int, card):
	if hands.has(index):
		hands[index].erase(card)
		discard_piles[index].append(card)
		emit_hand_state()

func get_card(index: int, card_type: String, cost: int):
	var hand = hands.get(index, [])
	return hand.find(func(c): return c.type == card_type and c.cost == cost)
