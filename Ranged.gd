extends Ability


var able_to_shoot: Array[Vector2i]


func mark(point: Vector2i, distance: int):
	able_to_shoot = grid.make_marking_ray(point, distance)
