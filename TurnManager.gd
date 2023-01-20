extends Node
class_name TurnManager


@onready var characters := get_tree().get_nodes_in_group("character")


func _ready() -> void:
	change_turn(characters[0])


func change_turn(character: Character):
	var current_index = characters.find(character)
	current_index = wrapi(current_index + 1, 0, characters.size())
	characters[current_index].start_turn()
