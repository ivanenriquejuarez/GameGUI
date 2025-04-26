extends Node2D

func _ready():
	for obj in DesignerState.pending_objects:
		var packed = load(obj["runtime_path"]) as PackedScene
		var pos = obj["position"]
		var instance = packed.instantiate()
		instance.global_position = pos
		
		# ✅ Apply saved scale if available
		if "scale" in obj:
			instance.scale = obj["scale"]
		else:
			instance.scale = Vector2(1, 1)  # Default to 1x if no scale saved
			
		
		add_child(instance)


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Designer/Designer.tscn")
