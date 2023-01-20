extends Node
class_name TurnManager


@onready var characters := get_tree().get_nodes_in_group("character")
@onready var characters_in_order := characters.duplicate()
@onready var camera = get_tree().get_first_node_in_group("camera")


func _ready() -> void:
	change_turn()


func change_turn():
	characters_in_order.sort_custom(sort_by_mind)
	var current_char = characters_in_order.pop_back()
	camera.master = current_char
	current_char.start_turn()
	if characters_in_order.is_empty(): characters_in_order = characters.duplicate()


func sort_by_mind(a: Character, b: Character) -> bool:
	if a.mind < b.mind: return true
	else: return false
	
