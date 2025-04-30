extends CanvasLayer
@onready var popup_grid = $PopupGrid
@onready var popup_settings = $PopupSettings
@onready var popup_load = $PopupLoad
var active_popup: Window = null  # Track the currently open popup
var last_button_pressed = ""     # Track last button name pressed

func _ready():
	$return.connect("pressed", Callable(self, "_on_return_pressed"))

func _on_grid_pressed():
	_handle_popup(popup_grid, "grid")
func _on_settings_pressed():
	_handle_popup(popup_settings, "settings")
func _on_load_pressed():
	_handle_popup(popup_load, "load")
func _handle_popup(popup_node: Window, button_name: String):
	if active_popup == popup_node and last_button_pressed == button_name:
		# If same popup and same button clicked again -> hide
		popup_node.hide()
		active_popup = null
		last_button_pressed = ""
	else:
		# Hide previous if different
		if active_popup:
			active_popup.hide()
		popup_node.popup_centered()
		active_popup = popup_node
		last_button_pressed = button_name

# Add this function to handle the return button press
func _on_return_pressed():
	# Change scene to the main menu
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
