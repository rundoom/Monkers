extends Node2D


@onready var grid = get_tree().get_first_node_in_group("grid") as Grid
@onready var astar = grid.astar as AStar2D
var current_path: Array[Vector2i]
var able_to_move: Array[Vector2i]
var max_move_points = 25
var current_move_points = max_move_points


func _ready() -> void:
	var grid_pos = grid.local_to_map(grid.to_local(global_position))
	var precise_position = grid.map_to_local(grid_pos)
	global_position = grid.to_global(precise_position)


func _on_target_pos_positioned(grid_position_target) -> void:
	if grid_position_target not in able_to_move or !$StepTimer.is_stopped(): return
	var grid_pos = grid.local_to_map(grid.to_local(global_position))
	var grid_id = grid.cells_map[grid_pos]

	current_path = Array(astar.get_point_path(grid_id, grid.cells_map[grid_position_target])).slice(1)
	var move_cost = current_path.reduce(func(acc, it): return acc + grid.astar.get_point_weight_scale(grid.cells_map[it]), 0)
	current_move_points -= move_cost

	if !current_path.is_empty():
		_on_step_timer_timeout()
		$StepTimer.start()


func mark_distance():
	var grid_pos = grid.local_to_map(grid.to_local(global_position))
	able_to_move = grid.make_marking(grid_pos, current_move_points)


func premark_path(target_pos: Vector2i):
	if !current_path.is_empty() or target_pos not in able_to_move: return
	
	$Movement.clear_points()
	var grid_pos = grid.local_to_map(grid.to_local(global_position))
	var grid_id = grid.cells_map[grid_pos]
	var pre_path = astar.get_point_path(grid_id, grid.cells_map[target_pos])
	for point in pre_path:
		var point_vec = grid.map_to_local(point) - position
		$Movement.add_point(point_vec)
	

func _on_step_timer_timeout() -> void:
	if current_path.is_empty():
		$StepTimer.stop()
		mark_distance()
		return
		
	var next_step = current_path.pop_front() as Vector2i
	var precise_position = grid.map_to_local(next_step)
	global_position = grid.to_global(precise_position)

	$Movement.clear_points()
	for point in current_path:
		var point_vec = grid.map_to_local(point) - position
		$Movement.add_point(point_vec)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		current_move_points = max_move_points
		mark_distance()
