extends Node2D

@export var main_scene: PackedScene = preload("res://Screens/Main/Main.tscn")
@export var music : AudioStream

func _ready() -> void:
	AudioManager.play_music(music)
	print("splash scene")
	
func _input(event):
	if event.is_pressed():
		get_tree().change_scene_to_packed(main_scene)  # Switch scenes on any input

func _on_exit():
	pass
