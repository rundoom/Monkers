extends Node2D
class_name Character


@onready var grid = get_tree().get_first_node_in_group("grid") as Grid
@onready var turn_manager = get_tree().get_first_node_in_group("turn_manager")
@onready var is_ready := true
@onready var occluder := $PositionPresenter

signal multiplier_changed(val)
var abilities_at_turn := 0:
	set(value):
		abilities_at_turn = value
		multiplier_changed.emit(fibonacci(value))

var current_multiplier: int:
	get: return fibonacci(abilities_at_turn)

signal body_changed(val)
signal spirit_changed(val)
signal mind_changed(val)

signal max_body_changed(val)
signal max_spirit_changed(val)
signal max_mind_changed(val)

@export var max_body: int:
	set(value):
		max_body = value
		max_body_changed.emit(value)
	
@onready var body: int = max_body:
	set(value):
		body = clamp(value, 0, 999)
		body_changed.emit(value)
		
@export var max_spirit: int:
	set(value):
		max_spirit = value
		max_spirit_changed.emit(value)
	
@onready var spirit: int = max_spirit:
	set(value):
		spirit = clamp(value, 0, 999)
		spirit_changed.emit(value)
		
@export var max_mind: int:
	set(value):
		max_mind = value
		max_mind_changed.emit(value)
	
@onready var mind: int = max_mind:
	set(value):
		mind = clamp(value, 0, 999)
		mind_changed.emit(value)

var ability_key_mapping := {"1":0,"2":1,"3":2,"4":3}

@onready var current_ability: Ability:
	set(new_ability):
		var is_marked: bool = false
		if new_ability != null:	is_marked = mark_ability(new_ability)
		if current_ability != null: current_ability.set_process_input(false)
		if is_marked: new_ability.set_process_input(true)
		if is_marked or new_ability == null: current_ability = new_ability
		

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
	turn_manager.change_turn()


func end_ability():
	current_ability = null
	grid.clear_marking()


func start_turn():
	if !is_ready: await ready
	set_process_input(true)
	$UILayer.visible = true
	abilities_at_turn = 0


func fibonacci(n):
	if n >= 0 and n <= 2:
		return n
	else:
		return fibonacci(n-1) + fibonacci(n-2)

func body_dmg(dmg):	if dmg > 0: body -= dmg + current_multiplier
func mind_dmg(dmg):	if dmg > 0: mind -= dmg + current_multiplier
func spirit_dmg(dmg): if dmg > 0: spirit -= dmg + current_multiplier


func init_setters():
	max_body = max_body
	body = body
	max_spirit = max_spirit
	spirit = spirit
	max_mind = max_mind
	mind = mind
	abilities_at_turn = abilities_at_turn
