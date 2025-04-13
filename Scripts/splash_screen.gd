extends Control

var can_proceed = true  # Set this to true immediately

func _ready():
	# Start splash music
	if get_node_or_null("/root/AudioManager") != null:
		get_node("/root/AudioManager").play_splash_music()
	
	print("Ready - press any key to continue")

func _input(event):
	# Only check for key or mouse button presses, ignore motion
	if can_proceed and event.is_pressed() and (event is InputEventKey or event is InputEventMouseButton):
		print("Key/button pressed - going to main menu")
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		can_proceed = false  # Prevent multiple transitions
