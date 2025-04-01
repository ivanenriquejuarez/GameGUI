@tool
extends Node2D

@export var cell_size : Vector2 = Vector2(64, 64)  # Default cell size (set in the inspector)
@export var grid_size : Vector2i = Vector2i(20, 15)  # Default number of cells (set in the inspector)

@onready var grid_controls: Control = $DesignerCamera/CanvasLayer/gridControls
@onready var grid_display: GridDisplay = $GridDisplay

signal button_pressed(button_name: String)

func _ready():
	# Connect the button signal
	connect("button_pressed", Callable(self, "handle_button_press"))
	
	# Ensure grid_controls starts hidden
	grid_controls.visible = false  
	
	# Apply initial settings from the inspector
	apply_grid_settings()

func apply_grid_settings():
	# Apply the preset grid size (instead of calculating it dynamically)
	if grid_display:
		grid_display.grid_size = grid_size
		grid_display.cell_size = cell_size  # Ensure the cell size is applied

# Example function to update cell size
func update_cell_size(new_size: Vector2):
	if grid_display:
		grid_display.cell_size = new_size

# Example function to toggle grid visibility
func toggle_grid():
	if grid_display:
		grid_display.draw_grid = !grid_display.draw_grid

# Example function to toggle border
func toggle_border():
	if grid_display:
		grid_display.draw_border = !grid_display.draw_border

# Handle button presses
func handle_button_press(button_name: String):
	match button_name:
		"grid_controls":
			grid_controls.visible = !grid_controls.visible  # Toggle visibility
		"designer_settings":
			print("Designer settings button pressed")
		"save_load":
			print("Save/Load button pressed")
			
# Called when the dropdown (OptionButton) changes (Cell Size)
func set_cell_size(index: int):
	# Get the selected cell size from the OptionButton
	var cell_size = int($DesignerCamera/CanvasLayer/gridControls/CenterContainer/VBoxContainer/OptionButton.get_item_text(index))  # Get the text of the selected item and convert it to an integer

	# Update the grid's cell size based on the selected option
	grid_display.cell_size = Vector2(cell_size, cell_size)

func set_line_and_border_width(value: float):
	# Ensure the value is within 1 to 5 range
	value = clamp(value, 1, 5)  # Clamps the value between 1 and 5
	grid_display.line_size = Vector2(value, value)
	grid_display.border_width = value

# Closes the UI panel
func close_ui():
	grid_controls.hide()


func _on_check_box_toggled(toggled_on: bool) -> void:
	grid_display.draw_grid = toggled_on
