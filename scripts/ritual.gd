class_name Ritual
extends MeshInstance3D

signal ritual_triggered(respawn_position: Vector3)

var owner_player = null
var _used := false

func activate(player) -> void:
	owner_player = player

func trigger_respawn() -> bool:
	if _used:
		return false
	_used = true
	ritual_triggered.emit(global_position)
	queue_free()
	return true
