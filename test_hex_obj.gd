extends Node2D
class_name Character


@onready var grid = get_tree().get_first_node_in_group("grid") as Grid

@export var max_body = 5:
	set(value):
		max_body = value
		%Body.max_value = value
	
var body = max_body:
	set(value):
		body = value
		%Body.value = value
		
@export var max_spirit = 5:
	set(value):
		max_spirit = value
		%Spirit.max_value = value
	
@export var spirit = max_spirit:
	set(value):
		spirit = value
		%Spirit.value = value
		
@export var max_mind = 5:
	set(value):
		max_mind = value
		%Mind.max_value = value
	
@export var mind = max_mind:
	set(value):
		mind = value
		%Mind.value = value


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
	init_setters()


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
	current_ability.init_ability(grid_pos)


func init_setters():
	max_body = max_body
	body = body
	max_spirit = max_spirit
	spirit = spirit
	max_mind = max_mind
	mind = mind
