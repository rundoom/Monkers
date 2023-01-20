extends Ability


var able_to_shoot: Array[Vector2i]
@export var aoe: int


func mark(point: Vector2i):
	able_to_shoot = grid.make_marking_ray(point, ability_range)


func premark_path(target_pos: Vector2i):
	if able_to_shoot.is_empty() or target_pos not in able_to_shoot: return
	
	var affected_area = grid.mark_ray(target_pos, aoe)
	grid.remark(affected_area)
