@tool
extends Node2D


@export var cell_size : Vector2 = Vector2(64, 64)  # Default cell size (e.g., 64x64)
@onready var grid_controls: Control = $DesignerCamera/CanvasLayer/gridControls
@onready var grid_display: GridDisplay = $GridDisplay

signal button_pressed(button_name: String)


# Define the custom signal
signal size_updated(new_size)

func _ready():
	# Connect the size_changed signal to a method that emits the custom signal
	connect("button_pressed", Callable(self, "handle_button_press"))
	grid_controls.visible = false  # Hide the grid controls by default
	update_grid_size()
	
# Emit the custom signal when the viewport size changes
func _on_size_changed():
	pass

# Example function to change grid size
func set_grid_size(new_size: Vector2i):
	if grid_display:
		grid_display.grid_size = new_size

# Example function to toggle grid visibility
func toggle_grid():
	if grid_display:
		grid_display.draw_grid = !grid_display.draw_grid

# Example function to toggle border
func toggle_border():
	if grid_display:
		grid_display.draw_border = !grid_display.draw_border
# Define a function that reacts to the button being pressed

func handle_button_press(button_name: String):
	match button_name:
		"grid_controls":
			# Handle grid controls button press
			grid_controls.visible = true
			# Add your logic here for handling the grid button press
		"designer_settings":
			# Handle designer settings button press
			print("Designer settings button pressed")
			# Add your logic here for settings
		"save_load":
			# Handle save/load button press
			print("Save/Load button pressed")
			# Add your logic here for saving/loading

func update_grid_size():
	# Get the viewport size (width and height)
	var viewport_size = get_viewport().size
	
	# Calculate the number of cells needed to fill the screen (considering the cell size)
	var grid_width = int(viewport_size.x / cell_size.x)  # Number of cells in the horizontal direction
	var grid_height = int(viewport_size.y / cell_size.y)  # Number of cells in the vertical direction
	
	# Adjust the grid size for GridDisplay
	grid_display.grid_size = Vector2(grid_width, grid_height)

	# Optionally, you can also adjust other properties like line size or border width if needed
	# For example:
	# grid_display.line_size = Vector2(1, 1)  # Example line size adjustment
