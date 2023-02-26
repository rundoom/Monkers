extends Control


var item_name: StringName
signal picked(val: bool)


func _ready() -> void:
	$Label.text = $Label.text.format([item_name])
	get_tree().paused = true


func _on_yes_pressed() -> void:
	picked.emit(true)
	get_tree().paused = false
	queue_free()


func _on_no_pressed() -> void:
	picked.emit(false)
	get_tree().paused = false
	queue_free()
