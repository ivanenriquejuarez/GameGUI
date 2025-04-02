extends Control

@export var scene_path: String
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

signal asset_selected(scene_path: String)

func _ready():
	var name = scene_path.get_file().get_basename()
	label.text = name

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("asset_selected", scene_path)
