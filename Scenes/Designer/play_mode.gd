extends Node2D

func _ready():
	for obj in DesignerState.pending_objects:
		var packed = load(obj["runtime_path"]) as PackedScene
		var pos = obj["position"]
		var instance = packed.instantiate()
		instance.global_position = pos
		add_child(instance)
