# Designer.gd (Parent Node of Canvas, responsible for emitting the signal)
extends Node

# Define the custom signal
signal size_updated(new_size)

func _ready():
	# Connect the size_changed signal to a method that emits the custom signal
	get_viewport().connect("size_changed", Callable(self, "_on_size_changed"))

# Emit the custom signal when the viewport size changes
func _on_size_changed():
	emit_signal("size_updated", get_viewport().size)  # Emit custom signal with new size
