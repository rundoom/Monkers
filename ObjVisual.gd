extends Polygon2D


func _ready() -> void:
	global_position = get_parent().global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = lerp(global_position, get_parent().global_position, 0.05) 
