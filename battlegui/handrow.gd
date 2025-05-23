extends HBoxContainer

signal card_used(hero_index: int, card_id: int, cost: int, panel: PanelContainer)

const CARD_COLORS := {
	"move":   Color(0, 0, 1, 0.5),
	"attack": Color(0, 0, 0, 0.5),
	"heal":   Color(0, 1, 0, 0.5),
}

var header_labels: Dictionary = {}

func _ready() -> void:
	clear_hand()  # only visual reset, no dummy data

func clear_hand() -> void:
	for child in get_children():
		child.queue_free()
	header_labels.clear()

func populate(hands_map: Dictionary) -> void:
	clear_hand()
	for hero_index in hands_map.keys():
		var hand = hands_map[hero_index] as Array
		var card_index = 0

		var col = VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_child(col)

		for card_dict in hand:
			var ctype = card_dict.get("type")
			var cost  = card_dict.get("cost")
			var bg    = CARD_COLORS.get(ctype, Color(0,0,0,0.5))

			var panel = PanelContainer.new()
			panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			panel.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
			panel.custom_minimum_size   = Vector2(48, 90)

			#var style = StyleBoxFlat.new()
			#style.bg_color = bg
			#style.border_color = Color(1,1,1,0.2)
			#panel.add_theme_stylebox("panel", style)

			var row = HBoxContainer.new()
			row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.size_flags_vertical   = Control.SIZE_FILL

			var lbl_cost = Label.new()
			lbl_cost.text = "   " + str(cost) + "  "
			row.add_child(lbl_cost)

			var lbl_name = Label.new()
			lbl_name.text = ctype.capitalize()
			lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(lbl_name)

			panel.add_child(row)
			col.add_child(panel)

			var card_id = card_dict.get("id", -1)
			panel.set_meta("card_id", card_id)
			panel.set_meta("hero_index", hero_index)
			panel.set_meta("cost", cost)
			panel.connect("gui_input", Callable(self, "_on_card_input").bind(panel))


func _on_card_input(event: InputEvent, panel: PanelContainer) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var hero_index = panel.get_meta("hero_index")
		var card_id = panel.get_meta("card_id")
		var cost = panel.get_meta("cost")
		emit_signal("card_used", hero_index, card_id, cost, panel)
