extends TileMap
class_name Grid


var astar := AStar2D.new()
var used_cell_positions: Array[Vector2i]
var TilePainter := preload("res://grid_painter.tscn")


class TileType:
	const EMPTY_CELL = Vector2i(-1, -1)
	const WATER = Vector2i(6, 0)
	const GRASS = Vector2i(0, 0)
	const FOREST = Vector2i(2, 0)


func _ready() -> void:
	used_cell_positions = get_used_cells(0)
	update()
	

func update() -> void:
	create_pathfinding_points()

	
func create_pathfinding_points() -> void:
	astar.clear()
	for cell_position in used_cell_positions:
		var weight = get_cell_tile_data(0, cell_position).custom_data_0
		
		if weight > 0: astar.add_point(calc_coord_id(cell_position), cell_position, weight)
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
#	set_cell(0, cell_pos, 1, cell_atlas, 1)


func make_marking(point: Vector2i, distance: int = 1):
	get_tree().call_group("tile_painter", "queue_free")
#	mark_move(point, distance, [point], PackedVector2Array())
	var avaliable_points = mark_move1(point, distance)
	for it in avaliable_points:
		var tile_painter = TilePainter.instantiate() as Polygon2D
		tile_painter.position = map_to_local(it)
		add_child(tile_painter)


func mark_move(point: Vector2i, distance, marked_tiles: PackedVector2Array, processed_tiles: PackedVector2Array) -> PackedVector2Array:
	if distance == 0: return marked_tiles
	
	processed_tiles.append(point)
	var surround = get_surrounding_cells(point)
	for it in surround:
		if !marked_tiles.has(it):
			var tile_painter = TilePainter.instantiate() as Polygon2D
			tile_painter.position = map_to_local(it)
			add_child(tile_painter)
			marked_tiles.append(it)
		
		if !processed_tiles.has(it):
			mark_move(it, distance - 1, marked_tiles, processed_tiles)
	
	return marked_tiles
	
func mark_move1(point: Vector2i, distance: int) -> Dictionary:
	var visited_points := {}
	var cost_so_far := {}
	var points_to_visit := [] as Array[Vector2i]
	points_to_visit.push_back(point)
	cost_so_far[point] = 0
	visited_points[point] = null
	
	while points_to_visit.size() > 0:
		var current_point = points_to_visit.pop_front()
		for surround in get_surrounding_cells(current_point):
			if get_cell_atlas_coords(0, surround) == TileType.EMPTY_CELL: continue
			var cost = get_cell_tile_data(0, surround).custom_data_0
			if cost < 0: continue
			
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
	return visited_points

func connect_cardinals(point_position) -> void:
	var center := calc_coord_id(point_position)
	if !astar.has_point(center): return
	
	var surroundings := get_surrounding_cells(point_position)
	for surrounding in surroundings:
		var surrounding_coord = calc_coord_id(surrounding)
		if !astar.has_point(surrounding_coord): continue
		astar.connect_points(center, calc_coord_id(surrounding), true)


func calc_coord_id(point: Vector2i) -> int:
	var x = point.x
	var y = point.y
	var a = 2 * x if x >= 0 else (-2 * x) - 1
	var b = 2 * y if y >= 0 else (-2 * y) - 1
	return a * a + a + b if a >= b else (b * b + a)
