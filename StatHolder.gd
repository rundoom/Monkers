extends Resource
class_name StatHolder


signal body_changed(val)
signal spirit_changed(val)
signal mind_changed(val)

@export var mind: int:
	set(value):
		mind = value
		mind_changed.emit(value)

@export var body: int:
	set(value):
		body = value
		body_changed.emit(value)
		
@export var spirit: int:
	set(value):
		spirit = value
		spirit_changed.emit(value)


func retarget_connections(mind_sig: Signal, body_sig: Signal, spirit_sig: Signal):
	mind_changed.connect(func(val): mind_sig.emit(val))
	body_changed.connect(func(val): body_sig.emit(val))
	spirit_changed.connect(func(val): spirit_sig.emit(val))
	refresh_values()


func add(other: StatHolder):
	body += other.body
	spirit += other.spirit
	mind += other.mind


func refresh_values():
	body_changed.emit(body)
	mind_changed.emit(mind)
	spirit_changed.emit(spirit)


func add_int(to_add: int):
	body += to_add
	spirit += to_add
	mind += to_add


func add_int_to_non_zero_dup(to_add: int) -> StatHolder:
	var new_holder = self.duplicate()
	
	if new_holder.body > 0 : new_holder.body += to_add
	if new_holder.spirit > 0 : new_holder.spirit += to_add
	if new_holder.mind > 0 : new_holder.mind += to_add
	
	return new_holder
	
	
func multiply_int_dup(to_add: int) -> StatHolder:
	var new_holder = self.duplicate()

	new_holder.body *= to_add
	new_holder.spirit *= to_add
	new_holder.mind *= to_add
	
	return new_holder


func is_gt(other: StatHolder) -> bool:
	if body > other.body \
	or spirit > other.spirit \
	or mind > other.mind: return true
	return false
	

func is_lt(other: StatHolder) -> bool:
	if body < other.body \
	or spirit < other.spirit \
	or mind < other.mind: return true
	return false


func equate(other: StatHolder):
	body = other.body
	spirit = other.spirit
	mind = other.mind
	

func subtract(other: StatHolder):
	body -= other.body
	spirit -= other.spirit
	mind -= other.mind
	
	
func subtract_above_zero(other: StatHolder):
	body = clamp(body - other.body, 0, 999)
	spirit = clamp(spirit - other.spirit, 0, 999)
	mind = clamp(mind - other.mind, 0, 999)
