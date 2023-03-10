extends Ability


var able_to_shoot: Array[Vector2i]
@export var aoe: int

@export var dmg: StatHolder


func mark(point: Vector2i, exclusion: CollisionObject2D = null):
	able_to_shoot = grid.make_marking_ray(point, targeting, ability_range, exclusion)


func premark_path(target_pos: Vector2i):
	if able_to_shoot.is_empty() or target_pos not in able_to_shoot: return
	
	var affected_area = grid.mark_ray(target_pos, aoe, targeting)
	grid.remark(affected_area)


func perform(_from_position: Vector2i, target_position: Vector2i):
	if target_position not in able_to_shoot: return
	
	var unit := grid.get_unit_in(target_position)
	if unit == null || !unit.owner.is_in_group("character"): return
	var target_char = unit.owner as Character
	
	target_char.recieve_dmg(dmg)
	for effect in $Effects.get_children():
		var dup = effect.create_instance()
		dup.get_parent().remove_child(dup)
		target_char.effects.add_child(dup)
	
	drain_stats()
	
	end_ability()
	
