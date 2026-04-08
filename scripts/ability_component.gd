class_name AbilityComponent

extends Node

@onready var player = $".."

var coin_flip_sfx = preload("res://assets/sfx/coin_flip.mp3")
var shotSFX = preload("res://assets/sfx/shot.mp3")
var nothingSFX = preload("res://assets/sfx/do_nothing.mp3")
var explodeSFX = preload("res://assets/sfx/test.ogg")
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
		await get_tree().create_timer(0.5).timeout
		
		var sfx_player = $"../SFX"
		sfx_player.stream = coin_flip_sfx
		sfx_player.play()
		var random = randf()
		if random < 0.75 and $"..".tokens < 3:
			$"..".tokens += 1
		elif random > 0.75:
			$"..".weakness += 1
			
	# shoot
	elif ability == "gun_shot":
		if $"..".tokens > 0 and not gunDestroyed:
			var tokens_used = $"..".tokens
			$"..".tokens = 0
			
			var random = randf()
			var shoot_chance: float
			var explode_chance: float
			
			$"..".current_speed = 0
			
			if tokens_used == 1:
				shoot_chance = 0.15
				explode_chance = 0.25  
			elif tokens_used == 2:
				shoot_chance = 0.40
				explode_chance = 0.55  
			else: 
				shoot_chance = 0.70
				explode_chance = 0.78  
				
			
			await get_tree().create_timer(0.8).timeout
			
			if random < shoot_chance:
				var hit_flag: Array = []
				var spawn_pos = $"..".global_position + $"..".transform.basis.y * 1.0
				spawn_pos -= $"..".transform.basis.z * 4.0
				spawn_pos.y -= 0.9
				$"../..".add_hitbox(
					$"..".hitboxes, spawn_pos, hit_flag, 25 * tokens_used, "killer", Vector3(0.5,0.25,5.558), $".."
				)
				$"../SFX".stream = shotSFX
				$"../SFX".play()
				await get_tree().create_timer(0.05).timeout
			elif random < explode_chance:
				gunDestroyed = true
				var hit_flag: Array = []
				var spawn_pos = $"..".global_position + -$"..".transform.basis.z * 1.0
				spawn_pos.y -= 0.9
				$"../..".add_hitbox(
					$"..".hitboxes, spawn_pos, hit_flag, 15 * tokens_used, "killer", Vector3(1.0,1.0,1.0), $".."
				)
				if $"..".weakness < 1:
					$"..".health -= 25 
				else:
					$"..".health -= 25 * $"..".weakness
				$"../SFX".stream = explodeSFX
				$"../SFX".play()
				await get_tree().create_timer(0.05).timeout
			else:
				$"../SFX".stream = nothingSFX
				$"../SFX".play()
		else:
			print("not enough tokens or gun is broken")
			
		$"..".current_speed = $"..".WALK_SPEED
			
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
	
	# hat fix
	elif ability == "reset" and player.tokens == 3:
		gunDestroyed = false
		player.weakness = 0
		
	# mouse attack
	elif ability == "mouse_attack":
		var camera = get_viewport().get_camera_3d()
		if not camera:
			return

		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_dir = camera.project_ray_normal(mouse_pos)

		var space = $"..".get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(
			ray_origin,
			ray_origin + ray_dir * 100.0
		)
		query.exclude = [$"..".get_rid()]  

		var result = space.intersect_ray(query)

		var target_pos: Vector3
		if result:
			target_pos = result.position
		else:
			target_pos = ray_origin + ray_dir * 50.0
			
		$"..".current_speed = 0
			
		
		await get_tree().create_timer(0.8).timeout

		_launch_mouse_projectile(target_pos)
		
		$"..".current_speed = $"..".WALK_SPEED
		
	else:
		print(ability)
	
func _launch_mouse_projectile(target_pos: Vector3) -> void:
	var start_pos = $"..".global_position
	start_pos.y -= 0.9  

	var direction = (target_pos - start_pos).normalized()
	var speed = 20.0         
	var max_distance = 40.0
	var min_distance = 1.5  
	var projectile_pos = start_pos
	var travelled = 0.0

	while travelled < max_distance:
		var step = speed * get_physics_process_delta_time()
		var next_pos = projectile_pos + direction * step

		var space = $"..".get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(projectile_pos, next_pos)
		query.exclude = [$"..".get_rid()]
		var result = space.intersect_ray(query)

		if result and travelled >= min_distance: 
			_spawn_explosion(result.position)
			return

		projectile_pos = next_pos
		travelled += step
		await get_tree().physics_frame

	_spawn_explosion(projectile_pos)

func _spawn_explosion(pos: Vector3) -> void:
	var hit_flag: Array = []
	$"../..".add_hitbox(
		$"..".hitboxes,
		pos,
		hit_flag,
		35,         
		"survivor",
		Vector3(3.0, 3.0, 3.0),  
		$".."
	)

func has_ability(ability_slot: String, survivor: String) -> bool:
	var survivor_data = CharData.get_survivor(survivor)
	var abilities: Array = survivor_data.get("abilities", [])
	for ab in abilities:
		if ab.get("id") == ability_slot:
			return true
	return false

func get_ability_survivor(ability_slot: String, survivor: String) -> Dictionary:
	var survivor_data = CharData.get_survivor(survivor)
	var abilities: Array = survivor_data.get("abilities", [])
	for ab in abilities:
		if ab.get("id") == ability_slot:
			return ab
	push_warning("[AbilityComponent] Ability slot '%s' not found for survivor '%s'" % [ability_slot, survivor])
	return {}

func get_killer_ability(ability_slot: String, killer: String):
	var killer_data = CharData.get_killer(killer)
	var abilities: Array = killer_data.get("abilities", [])
	for ab in abilities:
		if ab.get("id") == ability_slot:
			return ab
	push_warning("[AbilityComponent] Ability slot '%s' not found for killer '%s'" % [ability_slot, killer])
	return {}
