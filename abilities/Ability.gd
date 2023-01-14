extends Node
class_name Ability


@onready var grid = get_tree().get_first_node_in_group("grid") as Grid
var character: Character
var current_mouse_to_grid: Vector2i
@onready var astar = grid.astar as AStar2D
@export var ability_range: int

@export var body_cost: int
@export var spirit_cost: int
@export var mind_cost: int


func _ready() -> void:
	set_process_input(false)


func perform(from_position: Vector2i, target_position: Vector2i) -> void:
	pass
	
	
func mark(point: Vector2i) -> void:
	pass


func init_ability(point: Vector2i) -> void:
	if character.body < body_cost or character.spirit < spirit_cost or character.mind < mind_cost: return
	mark(point)

func premark_path(target_pos: Vector2i) -> void:
	pass


func drain_stats():
	character.body -= body_cost
	character.spirit -= spirit_cost
	character.mind -= mind_cost
