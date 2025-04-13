extends Control

func _ready():
	$ReturnButton.pressed.connect(_on_ReturnButton_pressed)

func _on_ReturnButton_pressed():
	print("Return button clicked!")
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
