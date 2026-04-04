extends Node

func add_hitbox(hitbox, pos, hit_flag: Array) -> void:
	var instance = hitbox.instantiate()
	instance.hit_flag = hit_flag
	$Hitboxes.add_child(instance)
	instance.global_position = pos
	
	await get_tree().create_timer(0.5).timeout
	instance.queue_free()
	
func _process(_delta: float) -> void:
	if get_player_count() > 1:
		start_intermission()

func get_player_count() -> int:
	return get_tree().get_nodes_in_group("players").size()

func start_intermission() -> void:
	$Intermission.start(30)
