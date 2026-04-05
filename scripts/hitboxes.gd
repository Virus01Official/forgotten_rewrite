extends Area3D

var hit_flag: Array = []
var damage = 25

func _on_body_entered(body: Node3D) -> void:
	if hit_flag.size() > 0:
		return
		
	if "isKiller" in body and not body.isKiller:
		if body.health > 0:
			hit_flag.append(true) 
			body.health -= damage
			_turn_green()

func _turn_green() -> void:
	var mesh = $CollisionShape3D/MeshInstance3D
	if mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color.GREEN
		mesh.material_override = mat
