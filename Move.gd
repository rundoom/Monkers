extends Ability


@onready var move_points: int = ability_range
var current_path: Array[Vector2i]
var able_to_move: Dictionary
var is_started = false


func perform(_from_position: Vector2i, target_position: Vector2i):
	if target_position not in able_to_move or !$StepTimer.is_stopped(): return
	
	if !is_started:
		is_started = true
		drain_stats()

	current_path = Array(track_path(target_position, able_to_move))
	current_path.reverse()
	current_path = current_path.slice(1)
	
	var move_cost = current_path.reduce(func(acc, it): return acc + grid.point_weight(it), 0)
	move_points -= move_cost

	if !current_path.is_empty():
		_on_step_timer_timeout()
		$StepTimer.start()


func mark(point: Vector2i):
	is_started = false
	move_points = ability_range
	able_to_move = grid.make_marking(point, move_points)


func continue_mark(point: Vector2i):
	able_to_move = grid.make_marking(point, move_points)


func premark_path(target_pos: Vector2i):
	if !current_path.is_empty() or target_pos not in able_to_move: return
	
	grid.remark(track_path(target_pos, able_to_move))


func track_path(target_pos: Vector2i, avaliable_routes: Dictionary) -> PackedVector2Array:
	var pre_path = PackedVector2Array()
	var next_point = target_pos
	
	while next_point != null:
		pre_path.append(next_point)
		next_point = avaliable_routes.get(next_point)
		
	return pre_path


func _on_step_timer_timeout() -> void:
	if current_path.is_empty():
		$StepTimer.stop()
		var grid_pos = grid.local_to_map(grid.to_local(character.global_position))
		continue_mark(grid_pos)
		return
		
	var next_step = current_path.pop_front() as Vector2i
	var precise_position = grid.map_to_local(next_step)
	character.global_position = grid.to_global(precise_position)
