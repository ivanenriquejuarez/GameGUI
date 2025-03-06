extends Node2D

@export var designer_scene: PackedScene = preload("res://Screens/Designer/Designer.tscn")
@export var music: AudioStream
@export var main_load_scene: PackedScene = preload("res://UIElements/MainLoad/main_load.tscn")
@export var main_settings_scene: PackedScene = preload("res://UIElements/MainSettings/main_settings.tscn")
@onready var audio_select: AudioStreamPlayer2D = $audio_select
@onready var main_ui: MarginContainer = $Camera2D/main_ui

var load_panel: Control
var settings_panel: Control

func _ready():
	$Camera2D/main_ui/HBoxContainer/VBoxContainer/new_project.pressed.connect(_on_new_project_pressed)
	$Camera2D/main_ui/HBoxContainer/VBoxContainer/load_project.pressed.connect(_on_load_project_pressed)
	$Camera2D/main_ui/HBoxContainer/VBoxContainer/settings.pressed.connect(_on_settings_pressed)
	AudioManager.play_music(music)
	print("main scene")

func _on_new_project_pressed():
	audio_select.play()
	get_tree().change_scene_to_packed(designer_scene)

func _on_load_project_pressed():
	# Instance and add the Load Project panel
	audio_select.play()
	main_ui.visible = false
	load_panel = main_load_scene.instantiate()
	add_child(load_panel)
	load_panel.visible = true

func _on_settings_pressed():
	# Instance and add the Settings panel
	audio_select.play()
	main_ui.visible = false
	settings_panel = main_settings_scene.instantiate()
	add_child(settings_panel)
	settings_panel.visible = true

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # "Esc" key by default
		# Hide and delete the panels when Esc is pressed
		if load_panel and load_panel.visible:
			load_panel.close_panel()  # Call the close_panel method to print and free the panel
			load_panel = null  # Prevent further attempts to free the panel
		if settings_panel and settings_panel.visible:
			settings_panel.close_panel()  # Delete Settings panel
			settings_panel = null  # Prevent further attempts to free the panel panel
		main_ui.visible = true
