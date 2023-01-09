extends Node
class_name Ability


@onready var grid = get_tree().get_first_node_in_group("grid") as Grid
var character: Node2D
var current_mouse_to_grid: Vector2i
@onready var astar = grid.astar as AStar2D
@export var ability_range: int


func _ready() -> void:
	set_process_input(false)


func perform(from_position: Vector2i, target_position: Vector2i) -> void:
	pass
	
	
func mark(point: Vector2i) -> void:
	pass


func premark_path(target_pos: Vector2i) -> void:
	pass
