class_name AbilityComponent

extends Node

func _activate_ability(ability: String) -> void:
	if ability == "slash":
		var hit_flag: Array = []
		for i in range(5):
			var spawn_pos = $"..".global_position + -$"..".transform.basis.z * 1.0
			spawn_pos.y -= 0.9
			$"../..".add_hitbox($"..".hitboxes, spawn_pos, hit_flag, 25)
			await get_tree().create_timer(0.05).timeout
	else:
		print(ability)
		
func get_ability_survivor(ability: String, survivor: String):
	var ab = CharData.get_survivor(survivor).get(ability, "ability1")
	return ab
