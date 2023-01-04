extends TileMap
class_name Grid


var astar := AStar2D.new()
var cells_map := {}
var TilePainter := preload("res://grid_painter.tscn")
var pool_marked : Array[Node2D] = []
var marked_in_use = 0


class TileType:
	const EMPTY_CELL = Vector2i(-1, -1)
	const WATER = Vector2i(6, 0)
	const GRASS = Vector2i(0, 0)
	const FOREST = Vector2i(2, 0)


func _ready() -> void:
	prepare_marked()
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
	$GridDebug.text = str(cell_atlas)


func make_marking(point: Vector2i, distance: int = 1) -> Array[Vector2i]:
	var avaliable_points = mark_move(point, distance)
	clear_marked()
	for it in avaliable_points: mark(it)
	
	return avaliable_points.keys()


func prepare_marked() -> void:
	for i in 1024:
		var tile_painter = TilePainter.instantiate() as Polygon2D
		tile_painter.visible = false
		pool_marked.append(tile_painter)
		add_child(tile_painter)
	
	
func clear_marked() -> void:
	for marked in pool_marked:
		marked.visible = false
	marked_in_use = 0
  

func mark(pos: Vector2i):
	if marked_in_use >= pool_marked.size():
		var new_marker = TilePainter.instantiate() as Polygon2D
		pool_marked.append(new_marker)
		add_child(new_marker)
	pool_marked[marked_in_use].position = map_to_local(pos)
	pool_marked[marked_in_use].show()
	marked_in_use += 1

	
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
			if !cells_map.has(surround): continue
			var cost = astar.get_point_weight_scale(cells_map[surround])
			
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


func connect_cardinals(point_position) -> void:
	var center = cells_map.get(point_position)
	if center == null: return
	
	var surroundings := get_surrounding_cells(point_position)
	for surrounding in surroundings:
		var surrounding_coord = cells_map.get(surrounding)
		if surrounding_coord == null: continue
		astar.connect_points(center, cells_map[surrounding], true)
