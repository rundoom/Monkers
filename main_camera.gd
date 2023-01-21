extends Camera2D

var master: Character


func _process(_delta: float) -> void:
	if master != null: global_position = lerp(global_position, master.global_position, 0.05)
