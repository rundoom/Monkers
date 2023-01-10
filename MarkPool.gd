extends Object
class_name MarkPool


var mark_pool : Array[Polygon2D] = []
var mark_in_use : Array[Polygon2D] = []
var TilePainter := preload("res://grid_painter.tscn")
var master: Node2D


func _init(master: Node2D) -> void:
	self.master = master
	prepare_marked()


func prepare_marked() -> void:
	for i in 1024:
		var tile_painter = TilePainter.instantiate() as Polygon2D
		tile_painter.visible = false
		mark_pool.append(tile_painter)
		master.add_child(tile_painter)
		
		
func get_marker() -> Polygon2D:
	var new_marker: Polygon2D
	if mark_pool.is_empty():
		new_marker = TilePainter.instantiate() as Polygon2D
		mark_in_use.append(new_marker)
		master.add_child(new_marker)
	else:
		new_marker = mark_pool.pop_back()
		mark_in_use.append(new_marker)
	new_marker.show()
	
	return new_marker
	
	
func release_marker(marker: Polygon2D) -> void:
	marker.hide()
	mark_pool.append(marker)
	mark_in_use.erase(marker)
	

func release_all() -> void:
	for marker in mark_in_use: marker.hide()
	mark_pool.append_array(mark_in_use)
	mark_in_use.clear()
