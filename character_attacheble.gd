extends Node2D
class_name CharacterAttacheble


var character: Character


func set_on_character(character: Character):
	self.character = character
	owner = character
	hide()
	var hitboxes = find_children("", "CollisionPolygon2D")
	for hitbox in hitboxes:
		hitbox.disabled = true
