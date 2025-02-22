extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("settings")


func close_panel() -> void:
	print("exit settings")  # Print when the panel closes
	queue_free()  # Free the panel
