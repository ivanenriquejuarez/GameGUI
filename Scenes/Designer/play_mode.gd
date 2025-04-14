extends Node2D

func _ready():
	for obj in DesignerState.pending_objects:
		var packed = obj["scene"]
		var position = obj["position"]
		var instance = packed.instantiate() as Node2D
		instance.global_position = position
		add_child(instance)
