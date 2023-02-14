extends Node2D
class_name Character


@onready var grid = get_tree().get_first_node_in_group("grid") as Grid
@onready var turn_manager = get_tree().get_first_node_in_group("turn_manager")
@onready var is_ready := true
@onready var occluder := $PositionPresenter
var abilities_at_turn := 0
var current_multiplier: int:
	get: return fibonacci(abilities_at_turn)


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
	"2" : 1,
	"3" : 2,
	"4" : 3
}

@onready var current_ability: Ability:
	set(new_ability):
		var is_marked: bool = false
		if new_ability != null: is_marked = mark_ability(new_ability)
		
		if is_marked:
			if current_ability != null: current_ability.set_process_input(false)
			new_ability.set_process_input(true)
			current_ability = new_ability
		

func _ready() -> void:
	var grid_pos = grid.local_to_map(grid.to_local(global_position))
	var precise_position = grid.map_to_local(grid_pos)
	global_position = grid.to_global(precise_position)
	init_setters()
	
	set_process_input(false)
	$UILayer.visible = false


func _input(event: InputEvent) -> void:
	for mapped_key in ability_key_mapping:
		if event.is_action_pressed(mapped_key):
			current_ability = $AbilityPool.get_child(ability_key_mapping[mapped_key])
		
	if event.is_action_pressed("LMB") and current_ability != null:
		var grid_pos = grid.local_to_map(grid.to_local(get_global_mouse_position()))
		var char_grid = grid.local_to_map(grid.to_local(global_position))
		current_ability.perform(char_grid, grid_pos)
		
	if event.is_action_pressed("RMB"): end_ability()
		
	if event.is_action_pressed("ui_accept"): end_turn()


func mark_ability(ability: Ability) -> bool:
	var grid_pos = grid.local_to_map(grid.to_local(global_position))
	return ability.init_ability(grid_pos)


func end_turn():
	set_process_input(false)
	$UILayer.visible = false
	grid.clear_marking()
	if current_ability != null: current_ability.set_process_input(false)
	current_ability = null
	abilities_at_turn = 0
	turn_manager.change_turn()


func end_ability():
	current_ability = null
	abilities_at_turn += 1


func start_turn():
	if !is_ready: await ready
	set_process_input(true)
	$UILayer.visible = true


func fibonacci(n):
	return 1 if n < 2 else fibonacci(n-1) + fibonacci(n-2)


func init_setters():
	max_body = max_body
	body = body
	max_spirit = max_spirit
	spirit = spirit
	max_mind = max_mind
	mind = mind
