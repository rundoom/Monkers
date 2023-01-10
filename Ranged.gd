extends Ability


var able_to_shoot: Array[Vector2i]
@export var aoe: int


func mark(point: Vector2i):
	able_to_shoot = grid.make_marking_ray(point, ability_range)


func premark_path(target_pos: Vector2i):
	if able_to_shoot.is_empty() or target_pos not in able_to_shoot: return
	
	var affected_area = grid.mark_ray(target_pos, aoe)
	grid.remark(affected_area)
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var grid_pos = grid.local_to_map(grid.to_local(event.global_position))
		if grid_pos != current_mouse_to_grid:
			var precise_position = grid.map_to_local(grid_pos)
			current_mouse_to_grid = grid_pos
			premark_path(grid_pos)
