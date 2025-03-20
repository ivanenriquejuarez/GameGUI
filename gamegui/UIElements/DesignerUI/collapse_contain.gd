extends Control

@onready var button = $Button
@onready var content = $VBoxContainer

var is_expanded = false

func _ready():
	button.pressed.connect(_toggle_expand)

func _toggle_expand():
	is_expanded = !is_expanded
	content.visible = is_expanded
	
	# Tell the parent to close other containers
	if is_expanded:
		get_parent().collapse_others(self)
