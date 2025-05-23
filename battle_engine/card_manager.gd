extends Node

@onready var bm := get_parent()
@onready var hand_manager = bm.get_node("HandManager")
@onready var entity_manager = bm.get_node("EntityManager")
@onready var portrait_row = get_node("../../GUI/BottomPanel/PortraitRow")  # update path as needed
@onready var grid_manager = get_node("../../Tilemap")  # update path as needed
signal hero_ap_changed(hero_index: int, current_ap: int)

enum State { IDLE, SELECTING_CARD, TARGETING, EXECUTING }
var current_state: State = State.IDLE
var selected_card
var selected_hero_index
var range_tiles

func _ready():
	connect("hero_ap_changed", Callable(portrait_row, "update_ap_display_for"))
	
func start_player_phase():
	hand_manager.draw_phase()
	range_tiles = []

func can_play_card(hero, card, cost) -> bool:
	return hero.stats.current_ap >= cost

func _on_card_used(hero_index: int, card_id: int, cost: int, panel: PanelContainer):
	if current_state != State.IDLE:
		return  # prevent overlapping input

	var hero = entity_manager.get_all_player_units()[hero_index]
	var hand = hand_manager.get_hand(hero_index)
	var card = hand.filter(func(c): return c.has("id") and c["id"] == card_id).front()

	if not card:
		push_warning("Card not found in hand")
		return

	if not can_play_card(hero, card, cost):
		panel.modulate = Color(1, 0, 0, 0.6)
		return

	current_state = State.SELECTING_CARD
	start_targeting(hero_index, card)

func start_targeting(hero_index: int, card: Dictionary):
	selected_card = card
	selected_hero_index = hero_index
	current_state = State.TARGETING

	var origin = entity_manager.get_all_player_units()[hero_index].get_map_position()
	var range = 3  # or card.range
	#var tiles = grid_manager.get_tiles_in_range(origin, range)
	range_tiles = grid_manager.get_tiles_in_range_move(origin, range, "player")
	range_tiles.append(origin)
	grid_manager.highlight_tiles(range_tiles, "move")  # or "move", etc.
	
func _unhandled_input(event: InputEvent):
	if current_state == State.TARGETING and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_target_click()
		
func handle_target_click():
	var mouse_pos = get_viewport().get_mouse_position()
	var local_mouse = grid_manager.terrain_layer.to_local(mouse_pos)
	var clicked_tile = grid_manager.terrain_layer.local_to_map(local_mouse)

	if clicked_tile in range_tiles:
		print("✅ Tile selected:", clicked_tile)
		# Here you would later transition to EXECUTING or trigger card effect
	else:
		print("❌ Clicked outside range — canceling")
		grid_manager.clear_highlights()
		current_state = State.IDLE
