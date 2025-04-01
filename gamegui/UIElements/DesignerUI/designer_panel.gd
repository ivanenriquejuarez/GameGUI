# Control.gd (on the Control node)

extends Control

@export var designer_node : Node  # Reference to the Designer scene
@onready var grid_controls: Button = $PanelContainer/VBoxContainer/HBoxContainer/grid_controls
@onready var designer_settings: Button = $PanelContainer/VBoxContainer/HBoxContainer/designer_settings
@onready var save_load: Button = $PanelContainer/VBoxContainer/HBoxContainer/save_load

func _ready():
	# Ensure that designer_node is assigned either via Inspector or directly
	if designer_node == null:
		print("Designer node not assigned!")

	# Connect the button signals to emit the custom signal in the Designer
	grid_controls.pressed.connect(_on_grid_controls_pressed)
	designer_settings.pressed.connect(_on_designer_settings_pressed)
	save_load.pressed.connect(_on_save_load_pressed)

func _on_grid_controls_pressed():
	# Emit the custom signal in the Designer node
	if designer_node:
		designer_node.emit_signal("button_pressed", "grid_controls")

func _on_designer_settings_pressed():
	# Emit the custom signal in the Designer node
	if designer_node:
		designer_node.emit_signal("button_pressed", "designer_settings")

func _on_save_load_pressed():
	# Emit the custom signal in the Designer node
	if designer_node:
		designer_node.emit_signal("button_pressed", "save_load")
