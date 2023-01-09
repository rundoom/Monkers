extends Node2D


@onready var grid = get_tree().get_first_node_in_group("grid") as Grid


var ability_key_mapping := {
	"1" : 0,
	"2" : 1
}

@onready var current_ability: Ability:
	set(value):
		if current_ability != null: current_ability.set_process_input(false)
		value.set_process_input(true)
		current_ability = value
		mark_ability()


func _ready() -> void:
	var grid_pos = grid.local_to_map(grid.to_local(global_position))
	var precise_position = grid.map_to_local(grid_pos)
	global_position = grid.to_global(precise_position)


func _input(event: InputEvent) -> void:
	for mapped_key in ability_key_mapping:
		if event.is_action_pressed(mapped_key):
			current_ability = $AbilityPool.get_child(ability_key_mapping[mapped_key])
		
	if event.is_action_pressed("LMB") and current_ability != null:
		var grid_pos = grid.local_to_map(grid.to_local(event.global_position))
		var char_grid = grid.local_to_map(grid.to_local(global_position))
		current_ability.perform(char_grid, grid_pos)


func mark_ability():
	var grid_pos = grid.local_to_map(grid.to_local(global_position))
	current_ability.mark(grid_pos)
