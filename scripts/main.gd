extends Node

func add_hitbox(hitbox, pos, hit_flag: Array) -> void:
	var instance = hitbox.instantiate()
	instance.hit_flag = hit_flag
	$Hitboxes.add_child(instance)
	instance.global_position = pos
	
	await get_tree().create_timer(0.5).timeout
	instance.queue_free()
