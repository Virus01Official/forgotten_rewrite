class_name AbilityComponent

extends Node

func _activate_ability(ability: String) -> void:
	if ability == "slash":
		var hit_flag: Array = []
		for i in range(5):
			var spawn_pos = $"..".global_position + -$"..".transform.basis.z * 1.0
			spawn_pos.y -= 0.9
			$"../..".add_hitbox(
				$"..".hitboxes, spawn_pos, hit_flag, 25, "survivor", Vector3(1.0,1.0,1.0), $".."
			)
			await get_tree().create_timer(0.05).timeout
	elif ability == "luck_token":
		var random = randf()
		if random < 0.75 and $"..".tokens < 3:
			$"..".tokens += 1
		else:
			$"..".weakness += 1
	elif ability == "gun_shot":
		if $"..".tokens > 0:
			var hit_flag: Array = []
			var spawn_pos = $"..".global_position + $"..".transform.basis.y * 1.0
			spawn_pos -= $"..".transform.basis.z * 4.0
			spawn_pos.y -= 0.9
			$"../..".add_hitbox(
				$"..".hitboxes, spawn_pos, hit_flag, 25, "killer", Vector3(1.0,1.0,1.0), $".."
				)
			await get_tree().create_timer(0.05).timeout
	else:
		print(ability)
		
func get_ability_survivor(ability_slot: String, survivor: String) -> Dictionary:
	var survivor_data = CharData.get_survivor(survivor)
	var abilities: Array = survivor_data.get("abilities", [])
	for ab in abilities:
		if ab.get("id") == ability_slot:
			return ab
	push_warning("[AbilityComponent] Ability slot '%s' not found for survivor '%s'" % [ability_slot, survivor])
	return {}

func get_killer_ability(ability: String, killer: String):
	var ab = CharData.get_killer(killer).get(ability, "ability1")
	return ab
