# Canvas.gd (Parent of Grid node)
extends Control

# Called when the custom signal is emitted from the Designer node
func _ready():
	var designer = get_parent()  # Get the parent node, should be Designer
	if designer.has_signal("size_updated"):
		designer.connect("size_updated", Callable(self, "_on_size_updated"))

	# Debugging: Print the children of Canvas to see if Grid exists
	print("Children of Canvas:")
	for child in get_children():
		print(child.name)  # Print names of all children

# Forward the signal to the Grid node
func _on_size_updated(new_size: Vector2):
	# Try using "Grid" as the direct child node path
	var grid = get_node("Grid")  # Make sure to use the correct path
	if grid:
		grid._on_size_updated(new_size)  # Forward the signal to the Grid node
	else:
		print("Grid node not found!")  # Debugging: Print a message if Grid is not found
