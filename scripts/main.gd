extends Node

var intermission_started := false

func add_hitbox(hitbox, pos, hit_flag: Array, damage, Hittarget: String, size: Vector3, source_player = null) -> void:
	var instance = hitbox.instantiate()
	instance.hit_flag = hit_flag
	if Hittarget == 'survivor':
		instance.hit_killer = false
	else:
		instance.hit_killer = true
	instance.damage = damage
	
	var collision_shape = instance.get_node("CollisionShape3D")
	if collision_shape and collision_shape.shape:
		collision_shape.shape = collision_shape.shape.duplicate()
		collision_shape.shape.size = size
	
	$Hitboxes.add_child(instance)
	instance.global_position = pos
	
	if source_player:
		instance.global_rotation = source_player.global_rotation
	
	await get_tree().create_timer(0.5).timeout
	instance.queue_free()
	
func _process(_delta: float) -> void:
	if get_player_count() > 1 and not intermission_started:
		intermission_started = true
		start_intermission()
	else:
		for player in get_players():
			player.get_node("player_ui/SpectatorStuff/Label").text = \
				"Waiting for players"
		
	if $Intermission.time_left > 0:
		for player in get_players():
			player.get_node("player_ui/SpectatorStuff/Label").text = \
				"Intermission: " + str(snapped($Intermission.time_left, 1.0))

func get_player_count() -> int:
	return get_tree().get_nodes_in_group("players").size()
	
func get_players():
	return get_tree().get_nodes_in_group("players")

func start_intermission() -> void:
	$Intermission.start(30)
	
func start_round():
	var highest_malice = -INF
	var most_malicious_player = null
	
	for player in get_players():
		if player.malice > highest_malice:
			highest_malice = player.malice
			most_malicious_player = player
		
		player.get_node('player_ui').get_node('SpectatorStuff').visible = false
		player.get_node('player_ui').get_node('GameStuff').visible = false
	
	if most_malicious_player != null:
		print("Most malicious player is: ", most_malicious_player.name, 
			  " with malice: ", highest_malice)

func _on_intermission_timeout() -> void:
	start_round()
