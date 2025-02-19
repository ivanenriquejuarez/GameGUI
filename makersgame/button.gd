extends Button  # This tells Godot that this script extends the Button node

func _ready():
	connect("pressed", self._on_Button_pressed)  # Connect the button press signal

func _on_Button_pressed():
	print("Button Clicked!")  # Print message when button is pressed
