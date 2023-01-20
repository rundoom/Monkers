extends TileMap
class_name Grid


var astar := AStar2D.new()
var cells_map := {}
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


func _ready() -> void:
	update()
	

func update() -> void:
	create_pathfinding_points()

	
func create_pathfinding_points() -> void:
	astar.clear()
	var used_cell_positions = get_used_cells(0)
	
	for cell_position in used_cell_positions:
		var weight = get_cell_tile_data(0, cell_position).custom_data_0
		
		if weight > 0:
			var point_id = astar.get_available_point_id()
			cells_map[cell_position] = point_id
			astar.add_point(point_id, cell_position, weight)
		
	for cell_position in used_cell_positions:
		connect_cardinals(cell_position)


func get_used_cell_global_positions() -> Array:
	var cells = get_used_cells(0)
	var cell_positions := []
	for cell in cells:
		var cell_position := global_position + map_to_local(cell)
		cell_positions.append(cell_position)
	return cell_positions


func _physics_process(delta: float) -> void:
	var cell_pos = local_to_map(get_local_mouse_position())
	var cell_atlas = get_cell_atlas_coords(0, cell_pos)
	$GridDebug.text = str(cell_pos)


func make_marking(point: Vector2i, distance: int = 1) -> Array[Vector2i]:
	pool_remarked.clear()
	mark_pool.release_all()
	var avaliable_points = mark_move(point, distance)
	var color = MarkColors.MOVE
	for it in avaliable_points: mark(it, color)
	
	return avaliable_points
	

func clear_marking():
	pool_remarked.clear()
	mark_pool.release_all()
	

func make_marking_ray(point: Vector2i, distance: int = 1) -> Array[Vector2i]:
	pool_remarked.clear()
	mark_pool.release_all()
	var avaliable_points = mark_ray(point, distance)
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
	
	
func mark_move(point: Vector2i, distance: int) -> Array[Vector2i]:
	var visited_points := []
	var cost_so_far := {}
	var points_to_visit := [] as Array[Vector2i]
	points_to_visit.push_back(point)
	cost_so_far[point] = 0
	visited_points.append(point)
	
	while !points_to_visit.is_empty():
		var current_point = points_to_visit.pop_front()
		for surround in get_surrounding_cells(current_point):
			if !cells_map.has(surround): continue
			var cost = astar.get_point_weight_scale(cells_map[surround])
			
			var current_cost = cost_so_far[current_point]
			var new_cost = cost + current_cost
			
			if new_cost <= distance:
				if !visited_points.has(surround):
					visited_points.append(surround)
					cost_so_far[surround] = new_cost
					points_to_visit.push_back(surround)
				elif cost_so_far[surround] > new_cost:
					cost_so_far[surround] = new_cost
	
	visited_points.erase(point)
	return visited_points


func mark_ray(point: Vector2i, distance: int, erase_center: bool = false) -> Array[Vector2i]:
	var visited_points := []
	var cost_so_far := {}
	var points_to_visit := [] as Array[Vector2i]
	points_to_visit.push_back(point)
	cost_so_far[point] = 0
	visited_points.append(point)
	
	while !points_to_visit.is_empty():
		var current_point = points_to_visit.pop_front()
		for surround in get_surrounding_cells(current_point):
			if !_intersect_filter(surround, point): continue
			var current_cost = cost_so_far[current_point]
			var new_cost = current_cost + 1
			
			if new_cost <= distance and !visited_points.has(surround):
				visited_points.append(surround)
				cost_so_far[surround] = new_cost
				points_to_visit.push_back(surround)
	
	if erase_center: visited_points.erase(point)
	return visited_points


func _intersect_filter(visitor: Vector2i, from: Vector2i) -> bool:
	var ray = PhysicsRayQueryParameters2D.create(map_to_local(from), map_to_local(visitor), 1)
	var intersect = space_state.intersect_ray(ray)
	return true if intersect.is_empty() else false


func connect_cardinals(point_position) -> void:
	var center = cells_map.get(point_position)
	if center == null: return
	
	var surroundings := get_surrounding_cells(point_position)
	for surrounding in surroundings:
		var surrounding_coord = cells_map.get(surrounding)
		if surrounding_coord == null: continue
		astar.connect_points(center, cells_map[surrounding], true)
