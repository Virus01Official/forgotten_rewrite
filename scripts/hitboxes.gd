extends Area3D

var hit_flag: Array = []

func _on_body_entered(body: Node3D) -> void:
	if hit_flag.size() > 0:
		return
		
	if "isKiller" in body and not body.isKiller:
		if body.health > 0:
			hit_flag.append(true) 
			body.health -= 25
			_turn_green()
		else:
			print("ded")

func _turn_green() -> void:
	var mesh = $CollisionShape3D/MeshInstance3D
	if mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color.GREEN
		mesh.material_override = mat
