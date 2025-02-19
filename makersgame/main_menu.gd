extends Control

func _ready():
	$StartButton.connect("pressed", _on_start_pressed)
	$SettingsButton.connect("pressed", _on_settings_pressed)
	$QuitButton.connect("pressed", _on_quit_pressed)

func _on_start_pressed():
	print("Start button clicked! Load the next scene")

func _on_settings_pressed():
	print("Settings button clicked! Open settings UI")

func _on_quit_pressed():
	get_tree().quit()
