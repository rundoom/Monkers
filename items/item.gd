extends CharacterAttacheble


@onready var grid = get_tree().get_first_node_in_group("grid") as Grid
@export var item_name: String


func _ready() -> void:
	var grid_pos = grid.local_to_map(grid.to_local(global_position))
	var precise_position = grid.map_to_local(grid_pos)
	global_position = grid.to_global(precise_position)

