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
