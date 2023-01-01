extends Control


@onready var board = get_parent() as TileMap
@onready var astar = board.astar as AStar2D


func _draw():
	var points = astar.get_point_ids()
	for point in points:
		var connections = astar.get_point_connections(point)
		for connection in connections:
			var point_vec = board.map_to_local(astar.get_point_position(point))
			var connection_vec = board.map_to_local(astar.get_point_position(connection))
			draw_line(point_vec, connection_vec, Color.WHITE)
