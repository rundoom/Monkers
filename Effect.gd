extends CharacterAttacheble
class_name Effect


@export var duration: int
@export var stats_changed: StatHolder


func apply_effect():
	character.recieve_dmg(stats_changed)
	duration -= 1
	if duration < 1:
		queue_free()
