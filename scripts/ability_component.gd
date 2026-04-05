class_name AbilityComponent

extends Node

@onready var player = $".."

var coin_flip_sfx = preload("res://assets/sfx/coin_flip.mp3")
var gunDestroyed = false

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
			
	# coin flip
	elif ability == "luck_token":
		var sfx_player = $"../SFX"
		sfx_player.stream = coin_flip_sfx
		sfx_player.play()
		var random = randf()
		if random < 0.75 and $"..".tokens < 3:
			$"..".tokens += 1
		else:
			$"..".weakness += 1
			
	# shoot
	elif ability == "gun_shot":
		if $"..".tokens > 0 and not gunDestroyed:
			var tokens_used = $"..".tokens
			$"..".tokens = 0
			
			var random = randf()
			var shoot_chance: float
			var explode_chance: float
			
			if tokens_used == 1:
				shoot_chance = 0.15
				explode_chance = 0.25  
			elif tokens_used == 2:
				shoot_chance = 0.40
				explode_chance = 0.55  
			else: 
				shoot_chance = 0.70
				explode_chance = 0.78  
			
			if random < shoot_chance:
				var hit_flag: Array = []
				var spawn_pos = $"..".global_position + $"..".transform.basis.y * 1.0
				spawn_pos -= $"..".transform.basis.z * 4.0
				spawn_pos.y -= 0.9
				$"../..".add_hitbox(
					$"..".hitboxes, spawn_pos, hit_flag, 25 * tokens_used, "killer", Vector3(0.5,0.25,5.558), $".."
				)
				await get_tree().create_timer(0.05).timeout
			elif random < explode_chance:
				gunDestroyed = true
				var hit_flag: Array = []
				var spawn_pos = $"..".global_position + -$"..".transform.basis.z * 1.0
				spawn_pos.y -= 0.9
				$"../..".add_hitbox(
					$"..".hitboxes, spawn_pos, hit_flag, 15 * tokens_used, "survivor", Vector3(1.0,1.0,1.0), $".."
				)
				await get_tree().create_timer(0.05).timeout
		else:
			print("not enough tokens or gun is broken")
			
	#reroll
	elif ability == "health_gamble":
		if $"..".tokens > 0:
			var ability_data = get_ability_survivor("ability3", $"..".equipped_survivor)
			var min_health = ability_data.get("min_health", 60)
			var max_health = ability_data.get("max_health", 130)
			
			if player.health == player.maxhealth:
				player.maxhealth = randi_range(min_health, max_health)
				player.health = player.maxhealth
				print(str(player.health))
			else:
				player.maxhealth = randi_range(min_health, max_health)
	
	#hat fix
	elif ability == "reset" and player.tokens == 3:
		gunDestroyed = false
		player.weakness = 0
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
	
func has_ability(ability_slot: String, survivor: String) -> bool:
	var survivor_data = CharData.get_survivor(survivor)
	var abilities: Array = survivor_data.get("abilities", [])
	for ab in abilities:
		if ab.get("id") == ability_slot:
			return true
	return false

func get_killer_ability(ability: String, killer: String):
	var ab = CharData.get_killer(killer).get(ability, "ability1")
	return ab
