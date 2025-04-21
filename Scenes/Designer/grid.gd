# Grid.gd (Responsible for drawing the grid)
extends Node2D

@export var grid_size: int = 32  # Grid size (16, 32, 64)
@onready var canvas : Control = $".."  # Reference to the parent Canvas node

var previous_size: Vector2 = Vector2.ZERO

func _ready():
	# Initial grid draw
	draw_grid()

# Called when the custom signal is forwarded from the Canvas node
func _on_size_updated(new_size: Vector2):
	# Only update if the size has actually changed
	if new_size != previous_size:
		draw_grid()  # Redraw the grid
		previous_size = new_size  # Update the previous size

func draw_grid():
	# Clear existing grid lines from previous drawings
	for line in canvas.get_children():
		line.queue_free()  # Remove all previous Line2D nodes

	# Get the screen size
	var screen_size = get_viewport().size

	# Calculate the number of lines based on screen size and grid size
	var width_lines = int(screen_size.x / grid_size) + 1
	var height_lines = int(screen_size.y / grid_size) + 1

	# Set grid line color and width (will apply to each new Line2D)
	var line_color = Color(1, 1, 1, 0.5)  # White color with 50% opacity

	# Draw horizontal lines (top to bottom)
	for i in range(height_lines):
		var y = i * grid_size
		if y <= screen_size.y:  # Ensure it doesn't go past the screen height
			var horizontal_line = Line2D.new()  # Create a new Line2D for each line
			horizontal_line.default_color = line_color
			horizontal_line.width = 1  # Set line width
			horizontal_line.add_point(Vector2(0, y))  # Start at the left edge
			horizontal_line.add_point(Vector2(screen_size.x, y))  # End at the right edge
			canvas.call_deferred("add_child", horizontal_line)  # Add the horizontal line to the Canvas

	# Draw vertical lines (left to right)
	for i in range(width_lines):
		var x = i * grid_size
		if x <= screen_size.x:  # Ensure it doesn't go past the screen width
			var vertical_line = Line2D.new()  # Create a new Line2D for each line
			vertical_line.default_color = line_color
			vertical_line.width = 1  # Set line width
			vertical_line.add_point(Vector2(x, 0))  # Start at the top edge
			vertical_line.add_point(Vector2(x, screen_size.y))  # End at the bottom edge
			canvas.call_deferred("add_child", vertical_line)  # Add the vertical line to the Canvas
