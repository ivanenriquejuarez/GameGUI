extends CanvasLayer

func _ready():
	_make_ui_click_through(self)

func _make_ui_click_through(node):
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_make_ui_click_through(child)
