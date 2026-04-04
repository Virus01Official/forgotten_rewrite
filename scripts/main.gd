extends Node

func add_hitbox(hitbox, pos) -> void:
	var instance = hitbox.instantiate()
	$Hitboxes.add_child(instance)
	instance.global_position = pos
	
	await get_tree().create_timer(0.5).timeout
	instance.queue_free()
