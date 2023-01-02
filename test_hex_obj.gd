extends Node2D


@onready var grid = get_tree().get_first_node_in_group("grid") as Grid
@onready var astar = grid.astar as AStar2D
var current_path: Array[Vector2i]


func _ready() -> void:
	var grid_pos = grid.local_to_map(grid.to_local(global_position))
	var precise_position = grid.map_to_local(grid_pos)
	global_position = grid.to_global(precise_position)


func _on_target_pos_positioned(grid_position_target) -> void:
	var grid_pos = grid.local_to_map(grid.to_local(global_position))
	var grid_id = grid.calc_coord_id(grid_pos)

	current_path = Array(astar.get_point_path(grid_id, grid.calc_coord_id(grid_position_target)))
		
	if !current_path.is_empty():
		_on_step_timer_timeout()
		$StepTimer.start()
	

func _on_step_timer_timeout() -> void:
	if current_path.is_empty():
		$StepTimer.stop()
		return
		
	var next_step = current_path.pop_front() as Vector2i
	var precise_position = grid.map_to_local(next_step)
	global_position = grid.to_global(precise_position)

	$Movement.clear_points()
	for point in current_path:
		var point_vec = grid.map_to_local(point) - position
		$Movement.add_point(point_vec)
