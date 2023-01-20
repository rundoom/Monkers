extends Node
class_name TurnManager


@onready var characters := get_tree().get_nodes_in_group("character")
@onready var characters_in_order := characters.duplicate()


func _ready() -> void:
	change_turn()


func change_turn():
	characters_in_order.sort_custom(sort_by_mind)
	characters_in_order.pop_back().start_turn()
	if characters_in_order.is_empty(): characters_in_order = characters.duplicate()


func sort_by_mind(a: Character, b: Character) -> bool:
	if a.mind < b.mind: return true
	else: return false
	
