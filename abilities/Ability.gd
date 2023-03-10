extends CharacterAttacheble
class_name Ability


@onready var grid = get_tree().get_first_node_in_group("grid") as Grid
var current_mouse_to_grid: Vector2i
@export var ability_range: int

enum TARGETING {ground=1, character=2, exclude_center=4, myself=8}
@export_flags("ground", "character", "exclude_center", "myself") var targeting: int

@export var costs: StatHolder


func _ready() -> void:
	set_process_input(false)


func perform(_from_position: Vector2i, _target_position: Vector2i) -> void:
	pass
	
	
func mark(_point: Vector2i, exclusion: CollisionObject2D = null) -> void:
	pass


func init_ability(point: Vector2i) -> bool:
	if character.current_stats.is_lt(costs.multiply_int_dup(character.current_multiplier)): return false
	mark(point, character.occluder)
	return true


func set_on_character(character: Character):
	self.character = character
	owner = character
		

func premark_path(_target_pos: Vector2i) -> void:
	pass
	

func end_ability():
	character.end_ability()


func drain_stats():
	character.current_stats.subtract(costs.multiply_int_dup(character.current_multiplier))
	character.abilities_at_turn += 1


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var grid_pos = grid.local_to_map(grid.to_local(get_global_mouse_position()))
		if grid_pos != current_mouse_to_grid:
			var _precise_position = grid.map_to_local(grid_pos)
			current_mouse_to_grid = grid_pos
			premark_path(grid_pos)
