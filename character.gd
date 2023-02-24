extends Node2D
class_name Character


@onready var grid = get_tree().get_first_node_in_group("grid") as Grid
@onready var turn_manager = get_tree().get_first_node_in_group("turn_manager")
@onready var is_ready := true
@onready var occluder := $PositionPresenter
@onready var effects := $EffectPool


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

@export var max_stats: StatHolder
@export var current_stats: StatHolder
@export var is_max_stats: bool

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
	init_connections()
	if is_max_stats: current_stats.equate(max_stats)
	abilities_at_turn = abilities_at_turn
	
	set_process_input(false)
	$UILayer.visible = false


func test_sig(vals):
	print(vals)


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
	for effect in $EffectPool.get_children():
		effect.apply_effect()
	abilities_at_turn = 0


func fibonacci(n):
	if n >= 0 and n <= 2:
		return n
	else:
		return fibonacci(n-1) + fibonacci(n-2)


func recieve_dmg(dmg: StatHolder):
	current_stats.subtract_above_zero(dmg.add_int_to_non_zero_dup(current_multiplier))


func init_connections():
	current_stats.retarget_connections(mind_changed, body_changed, spirit_changed)
	max_stats.retarget_connections(max_mind_changed, max_body_changed, max_spirit_changed)
