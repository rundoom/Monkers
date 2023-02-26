extends TileMap
class_name Grid


var pool_remarked: Array[Polygon2D] = []
@onready var space_state := get_world_2d().direct_space_state
@onready var mark_pool = MarkPool.new($MarkerHolder)


class MarkColors:
	const MOVE = Color(0.16470588743687, 0.40000000596046, 1, 0.34509804844856)
	const REMARKED = Color(0, 0, 0, 0.45098039507866)
	const RANGED = Color(0.86274510622025, 0, 0.30588236451149, 0.34509804844856)
	const AOE = Color(0.86274510622025, 0, 0.0627451017499, 0.64705884456635)
	
class TileType:
	const EMPTY_CELL = Vector2i(-1, -1)
	const WATER = Vector2i(6, 0)
	const GRASS = Vector2i(0, 0)
	const FOREST = Vector2i(2, 0)


func get_used_cell_global_positions() -> Array:
	var cells = get_used_cells(0)
	var cell_positions := []
	for cell in cells:
		var cell_position := global_position + map_to_local(cell)
		cell_positions.append(cell_position)
	return cell_positions


func _physics_process(_delta: float) -> void:
	var cell_pos = local_to_map(get_local_mouse_position())
	var _cell_atlas = get_cell_atlas_coords(0, cell_pos)
	$GridDebug.text = str(cell_pos)


func make_marking(point: Vector2i, distance: int = 1) -> Dictionary:
	pool_remarked.clear()
	mark_pool.release_all()
	var avaliable_points = mark_move(point, distance)
	var color = MarkColors.MOVE
	for it in avaliable_points: mark(it, color)
	
	return avaliable_points
	

func clear_marking():
	pool_remarked.clear()
	mark_pool.release_all()
	

func make_marking_ray(point: Vector2i, targeting: int, distance: int = 1, exclusion: CollisionObject2D = null) -> Array[Vector2i]:
	pool_remarked.clear()
	mark_pool.release_all()
	var avaliable_points = mark_ray(point, distance, targeting, exclusion)
	var color = MarkColors.RANGED
	for it in avaliable_points: mark(it, color)
	
	return avaliable_points


func mark(pos: Vector2i, color: Color) -> Node2D:
	var new_marker := mark_pool.get_marker()
	new_marker.material.set("shader_parameter/filter_color", color)
	new_marker.position = map_to_local(pos)
	
	return new_marker


func remark(pos: Array[Vector2i]):
	for it in pool_remarked: mark_pool.release_marker(it)
	pool_remarked.clear()
	
	for it in pos:
		var remarked_node = mark(it, MarkColors.REMARKED)
		pool_remarked.append(remarked_node)
	
	
func mark_move(point: Vector2i, distance: int) -> Dictionary:
	var visited_points := {}
	var cost_so_far := {}
	var points_to_visit := [] as Array[Vector2i]
	points_to_visit.push_back(point)
	cost_so_far[point] = 0
	visited_points[point] = null
	
	while !points_to_visit.is_empty():
		var current_point = points_to_visit.pop_front()
		for surround in get_surrounding_cells(current_point):
			if !is_point_passable(surround): continue
			var cost = point_weight(surround)
			
			var current_cost = cost_so_far[current_point]
			var new_cost = cost + current_cost
			
			if new_cost <= distance:
				if !visited_points.has(surround):
					visited_points[surround] = current_point
					cost_so_far[surround] = new_cost
					points_to_visit.push_back(surround)
				elif cost_so_far[surround] > new_cost:
					cost_so_far[surround] = new_cost
					visited_points[surround] = current_point
	
	visited_points.erase(point)
	return visited_points


func mark_ray(point: Vector2i, distance: int, targeting: int, exclusion: CollisionObject2D = null) -> Array[Vector2i]:
	var visited_points := [] as Array[Vector2i]
	var cost_so_far := {}
	var points_to_visit := [] as Array[Vector2i]
	points_to_visit.push_back(point)
	cost_so_far[point] = 0
	visited_points.append(point)

	while !points_to_visit.is_empty():
		var current_point = points_to_visit.pop_front()
		for surround in get_surrounding_cells(current_point):
			if !_intersect_filter(surround, point, exclusion): continue
			
			var current_cost = cost_so_far[current_point]
			var new_cost = current_cost + 1
			
			if new_cost <= distance and !visited_points.has(surround):
				visited_points.append(surround)
				cost_so_far[surround] = new_cost
				points_to_visit.push_back(surround)
	
	if targeting & Ability.TARGETING.myself and get_unit_in(point): visited_points.append(point)
	return visited_points


func point_weight(point: Vector2i) -> float:
	return get_cell_tile_data(0, point).custom_data_0


func get_unit_in(point: Vector2i) -> Node2D:
	return _node_at_point(point, 1)


func get_item_in(point: Vector2i) -> Node2D:
	return _node_at_point(point, 2)


func _node_at_point(point: Vector2i, layer: int) -> Node2D:
	var interceptor_point = PhysicsPointQueryParameters2D.new()
	interceptor_point.position = map_to_local(point)
	interceptor_point.collision_mask = layer
	var colliders := space_state.intersect_point(interceptor_point)
	return colliders[0]["collider"] if !colliders.is_empty() else null


func is_point_passable(point: Vector2i) -> bool:
	return get_cell_atlas_coords(0, point) != TileType.EMPTY_CELL and \
		point_weight(point) != -1 and get_unit_in(point) == null


func _intersect_filter(visitor: Vector2i, from: Vector2i, exclude: CollisionObject2D = null) -> bool: 
	var excludes = [exclude.get_rid()] if exclude != null else []
	var ray = PhysicsRayQueryParameters2D.create(map_to_local(visitor), map_to_local(from), 1, excludes)
	var intersect = space_state.intersect_ray(ray)
	return true if intersect.is_empty() else false
