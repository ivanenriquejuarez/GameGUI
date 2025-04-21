extends VBoxContainer

func collapse_others(except):
	for child in get_children():
		if child != except and child is Control:
			child.content.visible = false
			child.is_expanded = false
