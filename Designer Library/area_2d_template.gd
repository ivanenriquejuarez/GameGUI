extends Area2D

@export var preview_path: String = ""  # This will be filled when placed
@export var runtime_path: String = ""

func _ready():
	input_event.connect(_on_input_event)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if DesignerState.cursor_is_empty():
			print("Picked up from placed preview:", preview_path)
			DesignerState.pick_up_preview(preview_path, runtime_path, get_parent())  # ✅ pass both paths
