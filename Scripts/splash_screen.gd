extends Control

var can_proceed = true
@onready var fade_rect := $Fade  # Reference to ColorRect

func _ready():
	fade_rect.modulate.a = 1.0
	var fade_in := create_tween()
	fade_in.tween_property(fade_rect, "modulate:a", 0.0, 1.0)  # Fade in over 1 second
	
	if get_node_or_null("/root/AudioManager") != null:
		get_node("/root/AudioManager").play_splash_music()
	print("Ready - press any key to continue")

func _input(event):
	if can_proceed and event.is_pressed() and (event is InputEventKey or event is InputEventMouseButton):
		print("Key/button pressed - starting fade out")
		can_proceed = false
		transition_to_main_menu()

func transition_to_main_menu():
	# Start fade-out
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0)  # Fade to black over 1 second
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
