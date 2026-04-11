class_name EffectComponent
extends Node

@onready var player = $".."

func activate_effect(effect: String, level: int) -> void:
	if effect == "invisibility":
		if level == 1:
			var mesh_instance = player.get_node('CollisionShape3D/MeshInstance3D')
			var material = mesh_instance.get_active_material(0)
			
			if material:
				var unique_mat = material.duplicate()
				unique_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				unique_mat.albedo_color.a = 0.5  
				mesh_instance.set_surface_override_material(0, unique_mat)
			else:
				push_error("No material found on MeshInstance3D! (>_<)")
	else:
		print(effect)

func deactivate_effect(effect: String):
	if effect == "invisibility":
		var mesh_instance = player.get_node('CollisionShape3D/MeshInstance3D')
		var material = mesh_instance.get_active_material(0)
			
		if material:
			var unique_mat = material.duplicate()
			unique_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			unique_mat.albedo_color.a = 1.0 
			mesh_instance.set_surface_override_material(0, unique_mat)
		else:
			push_error("No material found on MeshInstance3D! (>_<)")
