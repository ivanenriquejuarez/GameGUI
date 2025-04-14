extends Node2D

func _ready():
	$Area2D.connect("input_event", Callable(self, "_on_clicked"))

func _on_clicked(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if DesignerState.cursor_is_empty():
			DesignerState.pick_up(self)
