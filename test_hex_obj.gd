extends Node2D


@onready var grid = get_tree().get_first_node_in_group("grid") as Grid
@onready var astar = grid.astar as AStar2D
var current_path: Array[Vector2i]
var able_to_move: Array[Vector2i]
var max_move_points = 15
var current_move_points = max_move_points
var ray_spell_dist = 15
@onready var current_ability: Ability = $AbilityPool/Move
var current_mouse_to_grid: Vector2i


func _ready() -> void:
	var grid_pos = grid.local_to_map(grid.to_local(global_position))
	var precise_position = grid.map_to_local(grid_pos)
	global_position = grid.to_global(precise_position)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		current_move_points = max_move_points
		var grid_pos = grid.local_to_map(grid.to_local(global_position))
		current_ability.mark(grid_pos, current_move_points)
		
	if event.is_action_pressed("ray_spell"):
		current_move_points = max_move_points
		var grid_pos = grid.local_to_map(grid.to_local(global_position))
		able_to_move = grid.make_marking_ray(grid_pos, ray_spell_dist)
		
	if event.is_action_pressed("LMB"):
		var grid_pos = grid.local_to_map(grid.to_local(event.global_position))
		var char_grid = grid.local_to_map(grid.to_local(global_position))
		current_ability.perform(char_grid, grid_pos)
