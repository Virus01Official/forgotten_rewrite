extends Node

var intermission_started := false

func add_hitbox(hitbox, pos, hit_flag: Array) -> void:
	var instance = hitbox.instantiate()
	instance.hit_flag = hit_flag
	$Hitboxes.add_child(instance)
	instance.global_position = pos
	
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
	
