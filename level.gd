extends TileMap
class_name Grid


var astar := AStar2D.new()
var used_cell_positions: Array[Vector2i]
const EMPTY_CELL = Vector2i(-1, -1)


func _ready() -> void:
	used_cell_positions = get_used_cells(0)
	update()
	

func update() -> void:
	create_pathfinding_points()

	
func create_pathfinding_points() -> void:
	astar.clear()
	for cell_position in used_cell_positions:
		astar.add_point(calc_coord_id(cell_position), cell_position)
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


func connect_cardinals(point_position) -> void:
	var surroundings := get_surrounding_cells(point_position)
	var center := calc_coord_id(point_position)
	for surrounding in surroundings:
		if get_cell_atlas_coords(0, surrounding) == EMPTY_CELL: continue
		astar.connect_points(center, calc_coord_id(surrounding), true)


func calc_coord_id(point: Vector2i) -> int:
	var x = point.x
	var y = point.y
	var a = 2 * x if x >= 0 else (-2 * x) - 1
	var b = 2 * y if y >= 0 else (-2 * y) - 1
	return a * a + a + b if a >= b else (b * b + a)
