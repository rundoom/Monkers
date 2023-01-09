extends Ability


@onready var move_points: int = ability_range
var current_path: Array[Vector2i]
var able_to_move: Array[Vector2i]


func perform(from_position: Vector2i, target_position: Vector2i):
	var char_grid_id = grid.cells_map[from_position]
	var target_grid_id = grid.cells_map[target_position]

	if target_position not in able_to_move or !$StepTimer.is_stopped(): return

	current_path = Array(astar.get_point_path(char_grid_id, target_grid_id)).slice(1)
	var move_cost = current_path.reduce(func(acc, it): return acc + grid.astar.get_point_weight_scale(grid.cells_map[it]), 0)

	if !current_path.is_empty():
		_on_step_timer_timeout()
		$StepTimer.start()


func mark(point: Vector2i):
	able_to_move = grid.make_marking(point, move_points)


func mark_distance():
	var grid_pos = grid.local_to_map(grid.to_local(character.global_position))


func premark_path(target_pos: Vector2i):
	if !current_path.is_empty() or target_pos not in able_to_move: return
	
	var grid_pos = grid.local_to_map(grid.to_local(character.global_position))
	var grid_id = grid.cells_map[grid_pos]
	var pre_path = astar.get_point_path(grid_id, grid.cells_map[target_pos])
	grid.remark(pre_path)


func _on_step_timer_timeout() -> void:
	if current_path.is_empty():
		$StepTimer.stop()
		mark_distance()
		return
		
	var next_step = current_path.pop_front() as Vector2i
	var precise_position = grid.map_to_local(next_step)
	character.global_position = grid.to_global(precise_position)

	for point in current_path:
		var point_vec = grid.map_to_local(point) - character.position
#		$Movement.add_point(point_vec)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var grid_pos = grid.local_to_map(grid.to_local(event.global_position))
		if grid_pos != current_mouse_to_grid:
			var precise_position = grid.map_to_local(grid_pos)
			current_mouse_to_grid = grid_pos
			premark_path(grid_pos)
