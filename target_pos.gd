extends Marker2D

signal positioned(grid_position: Vector2i)

@onready var grid = get_tree().get_first_node_in_group("grid") as TileMap


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		var grid_pos = grid.local_to_map(grid.to_local(event.position))
		var precise_position = grid.map_to_local(grid_pos)
		global_position = grid.to_global(precise_position)
		emit_signal("positioned", grid_pos)
		
