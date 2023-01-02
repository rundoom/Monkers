extends Node2D


@onready var grid = get_tree().get_first_node_in_group("grid") as Grid
@onready var astar = grid.astar as AStar2D
var is_moving := false


func _ready() -> void:
	var grid_pos = grid.local_to_map(grid.to_local(global_position))
	var precise_position = grid.map_to_local(grid_pos)
	global_position = grid.to_global(precise_position)


func _on_target_pos_positioned(grid_position_target) -> void:
	$Movement.clear_points()
	var grid_pos = grid.local_to_map(grid.to_local(global_position))
	var grid_id = grid.calc_coord_id(grid_pos)

	var path = astar.get_point_path(grid_id, grid.calc_coord_id(grid_position_target))
	for point in path:
		var point_vec = grid.map_to_local(point) - position
		$Movement.add_point(point_vec)
