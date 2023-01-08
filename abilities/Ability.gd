extends Node
class_name Ability

@onready var grid = get_tree().get_first_node_in_group("grid") as Grid
#enum GridType {MOVING, TARGET, CONE, AOE}
#
#
#@export_enum(MOVING, TARGET, CONE, AOE) var ability_type: int


func perform(target_position: Vector2i):
	pass
	
	
func mark(point: Vector2i, distance: int):
	pass
