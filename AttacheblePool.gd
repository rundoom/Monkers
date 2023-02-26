extends Node


func _on_child_entered_tree(node: Node) -> void:
	node.set_on_character(owner)
