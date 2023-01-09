extends Node


func _on_child_entered_tree(node: Node) -> void:
	(node as Ability).character = owner
