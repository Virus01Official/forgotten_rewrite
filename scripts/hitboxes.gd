extends Area3D

var hit_flag: Array = []
var hit_killer = false
var damage = 25
var hitsfx = null
var og_plr = null
var is_back_attack = false

func _on_body_entered(body: Node3D) -> void:
	if hit_flag.size() > 0:
		return
		
	if "isKiller" in body and not body.isKiller and not hit_killer:
		if body.health > 0:
			hit_flag.append(true) 
			if body.weakness > 0:
				body.health -= damage * body.weakness
			else:
				body.health -= damage
			_turn_green()
			if og_plr:
				og_plr.get_node("SFX").stream = hitsfx
				og_plr.get_node("SFX").play()
	elif "isKiller" in body and body.isKiller and hit_killer:
		if body.health > 0:
			hit_flag.append(true) 
			body.health -= damage
			body.stunned = true
			_turn_green()
			if og_plr:
				_apply_oath(body)

func _apply_oath(killer_body: Node3D) -> void:
	if og_plr == null:
		return
	
	var killer_forward = -killer_body.global_transform.basis.z
	killer_forward.y = 0
	killer_forward = killer_forward.normalized()
	
	var to_attacker = og_plr.global_position - killer_body.global_position
	to_attacker.y = 0
	to_attacker = to_attacker.normalized()
	
	var dot = killer_forward.dot(to_attacker)
	print("dot value: ", dot)
	
	var oath_gain: float
	if dot > 0.0:  
		print("BACK ATTACK! oath +1.5 >:3")
		oath_gain = 1.5
	else:
		print("front attack... oath +1 owo")
		oath_gain = 1.0
	
	og_plr.oath = min(og_plr.oath + oath_gain, og_plr.max_oath)
	print("oath is now: ", og_plr.oath)

func _turn_green() -> void:
	var mesh = $CollisionShape3D/MeshInstance3D
	if mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color.GREEN
		mesh.material_override = mat
