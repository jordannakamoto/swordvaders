# res://ui/PortraitRow.gd
extends HBoxContainer

const HeroDefinitions = preload("res://entities/heroes/definitions.gd")

var ap_labels: Array[Label] = []

func populate(portrait_defs: Array) -> void:
	# 1) Clear previous children and AP label references
	for child in get_children():
		child.queue_free()
	ap_labels.clear()

	# 2) Get the hero instances
	var hero_manager = get_node("../../../Entities/Heroes")
	var heroes = hero_manager.get_all_heroes()

	# 3) Build one slot per portrait def
	for i in portrait_defs.size():
		var def = portrait_defs[i]
		var tex = def.get("texture")
		var offset = def.get("offset", Vector2.ZERO)
		if tex == null:
			push_warning("PortraitRow: null texture in def at index %d" % i)
			continue

		# ── slot container ──
		var slot = VBoxContainer.new()
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_child(slot)

		# ── AP label ──
		var lbl_ap = Label.new()
		lbl_ap.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		lbl_ap.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		if i < heroes.size():
			var hero = heroes[i]
			lbl_ap.text = "%d AP" % hero.get_stats().current_ap
		else:
			lbl_ap.text = "0 AP"

		slot.add_child(lbl_ap)
		ap_labels.append(lbl_ap)

		# ── Portrait TextureRect ──
		var rect = TextureRect.new()
		rect.texture = tex
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.custom_minimum_size = Vector2(300, 1000)
		rect.position = offset

		# ── Clipping band ──
		var clip = Control.new()
		clip.clip_contents = true
		clip.custom_minimum_size = Vector2(0, 80)
		clip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		clip.add_child(rect)

		# ── Add portrait under AP ──
		slot.add_child(clip)

func update_ap_display_for(index: int, ap: int) -> void:
	if index < ap_labels.size():
		ap_labels[index].text = "%d AP" % ap
