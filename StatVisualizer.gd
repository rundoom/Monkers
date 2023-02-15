extends StaticBody2D


func _on_mouse_entered() -> void:
	$StatsHolder.show()


func _on_mouse_exited() -> void:
	$StatsHolder.hide()
