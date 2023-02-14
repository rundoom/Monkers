extends StaticBody2D


func _on_mouse_entered() -> void:
	$StatVisualizer.show()


func _on_mouse_exited() -> void:
	$StatVisualizer.hide()
