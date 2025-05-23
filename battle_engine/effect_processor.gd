extends Node

# Grab the BattleManager parent
@onready var bm := get_parent()

func process_card_effect(card, source_entity, target = null):
	return # return for now
	for effect in card.effects:
		match effect.type:
			"move":
				bm.entity_manager.move_entity(source_entity, effect.target_pos)
			"damage":
				bm.entity_manager.apply_damage(effect.target, effect.amount)
			"status":
				bm.entity_manager.apply_status(effect.target, effect.status)
			_:
				push_warning("Unknown effect type: %s" % effect.type)
	# TODO: emit a “effects_done” signal so TurnManager or UI can resume
