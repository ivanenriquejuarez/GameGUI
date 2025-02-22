extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("load")

# Function to be called when closing the panel
func close_panel() -> void:
	print("exit load")  # Print when the panel closes
	queue_free()  # Free the panel
