extends Control

@onready var new_project_button = $VBoxContainer/NewGame
@onready var load_project_button = $VBoxContainer/LoadGame
@onready var settings_button = $VBoxContainer/Settings
@onready var exit_button = $VBoxContainer/Exit

func _ready():
	# Connect button signals
	new_project_button.pressed.connect(_on_new_project_pressed)
	load_project_button.pressed.connect(_on_load_project_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	# Hover sound
	new_project_button.mouse_entered.connect(_on_button_hovered)
	load_project_button.mouse_entered.connect(_on_button_hovered)
	settings_button.mouse_entered.connect(_on_button_hovered)
	exit_button.mouse_entered.connect(_on_button_hovered)

	# Press sound
	new_project_button.pressed.connect(_on_button_pressed)
	load_project_button.pressed.connect(_on_button_pressed)
	settings_button.pressed.connect(_on_button_pressed)
	exit_button.pressed.connect(_on_button_pressed)

	# Play main music if not already playing
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_main_music()


func _on_new_project_pressed():
	# Change scene to the designer scene
	get_tree().change_scene_to_file("res://Scenes/Designer/Designer.tscn")

func _on_load_project_pressed():
	get_tree().change_scene_to_file("res://Scenes/load_game.tscn")

func _on_settings_pressed():
	# Show settings menu
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")

func _on_exit_pressed():
	# Quit the game
	get_tree().quit()
	
func _on_button_hovered():
	ButtonHoverSound.play_hover_sound()
	
func _on_button_pressed():
	ButtonHoverSound.play_press_sound()
