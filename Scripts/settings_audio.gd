extends Control

@onready var map_settings_png = $CenterContainer/MapSettingPNG
@onready var master_slider = $CenterContainer/MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/MasterSlider
@onready var sfx_slider = $CenterContainer/MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/SFXSlider
@onready var music_slider = $CenterContainer/MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/MusicSlider
@onready var save_button = $CenterContainer/MapSettingPNG/popupMenu/baseMenu/NinePatchRect/MarginContainer/buttonContainer/topButtonContainer/SaveButton
@onready var exit_button = $CenterContainer/MapSettingPNG/popupMenu/baseMenu/NinePatchRect/MarginContainer/buttonContainer/topButtonContainer/ExitButton
@onready var return_button = $ReturnButton  # Add reference to return button

@onready var audio_tab = $CenterContainer/MapSettingPNG/Tab1
@onready var video_tab = $CenterContainer/MapSettingPNG/Tab2
@onready var control_tab = $CenterContainer/MapSettingPNG/Tab3

var original_master_volume: float
var original_sfx_volume: float
var original_music_volume: float
var previous_scene: String = "res://Scenes/main_menu.tscn"  # Default to main menu if no previous scene

func _ready():
	# Try to get the previous scene from metadata if available
	if get_tree().has_meta("previous_scene"):
		previous_scene = get_tree().get_meta("previous_scene")
		print("Previous scene found: ", previous_scene)
	else:
		print("No previous scene metadata found, using default: ", previous_scene)
	
	# Connect return button signal if it exists
	if has_node("ReturnButton"):
		$ReturnButton.pressed.connect(_on_return_button_pressed)
		$ReturnButton.mouse_entered.connect(_on_button_hovered)
		$ReturnButton.pressed.connect(_on_button_pressed)
		print("Return button connected successfully")
	else:
		print("Return button not found in the scene")
	
	# Adjust scaling nicely based on screen size
	if get_viewport().size.x < 1600:
		map_settings_png.scale = Vector2(0.7, 0.7)
	else:
		map_settings_png.scale = Vector2(1, 1)

	print("Audio tab found: ", audio_tab != null)
	print("Video tab found: ", video_tab != null)
	print("Control tab found: ", control_tab != null)

	# Load and assign grabber textures only
	var button_slider = load("res://Assets/buttonSlider.png")
	var button_highlight = load("res://Assets/buttonHighlight.png")

	if button_slider and button_highlight:
		var small_grabber = Image.new()
		small_grabber.copy_from(button_slider.get_image())
		small_grabber.resize(91, 91)
		var small_grabber_texture = ImageTexture.create_from_image(small_grabber)

		var small_highlight = Image.new()
		small_highlight.copy_from(button_highlight.get_image())
		small_highlight.resize(91, 91)
		var small_highlight_texture = ImageTexture.create_from_image(small_highlight)

		for s in [master_slider, sfx_slider, music_slider]:
			s.add_theme_icon_override("grabber", small_grabber_texture)
			s.add_theme_icon_override("grabber_highlight", small_highlight_texture)

	# Save original volume values
	original_master_volume = AudioManager.master_volume
	original_sfx_volume = AudioManager.sfx_volume
	original_music_volume = AudioManager.music_volume

	# Configure sliders
	master_slider.min_value = 0
	master_slider.max_value = 100
	sfx_slider.min_value = 0
	sfx_slider.max_value = 100
	music_slider.min_value = 0
	music_slider.max_value = 100

	master_slider.value = original_master_volume
	sfx_slider.value = original_sfx_volume
	music_slider.value = original_music_volume

	master_slider.value_changed.connect(_on_master_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	save_button.pressed.connect(_on_save_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	save_button.mouse_entered.connect(_on_button_hovered)
	exit_button.mouse_entered.connect(_on_button_hovered)
	save_button.pressed.connect(_on_button_pressed)
	exit_button.pressed.connect(_on_button_pressed)

	if audio_tab:
		audio_tab.pressed.connect(_on_audio_button_pressed)
		audio_tab.mouse_entered.connect(_on_button_hovered)
	if video_tab:
		video_tab.pressed.connect(_on_video_button_pressed)
		video_tab.mouse_entered.connect(_on_button_hovered)
	if control_tab:
		control_tab.pressed.connect(_on_control_button_pressed)
		control_tab.mouse_entered.connect(_on_button_hovered)

func _on_master_slider_value_changed(value):
	AudioManager.set_master_volume(value, false)

func _on_sfx_slider_value_changed(value):
	AudioManager.set_sfx_volume(value, false)

func _on_music_slider_value_changed(value):
	AudioManager.set_music_volume(value, false)

func _on_save_button_pressed():
	AudioManager.save_volume_settings()
	original_master_volume = AudioManager.master_volume
	original_sfx_volume = AudioManager.sfx_volume
	original_music_volume = AudioManager.music_volume
	print("Settings saved!")

func _on_exit_button_pressed():
	if AudioManager.master_volume != original_master_volume or \
	   AudioManager.sfx_volume != original_sfx_volume or \
	   AudioManager.music_volume != original_music_volume:
		AudioManager.set_master_volume(original_master_volume, false)
		AudioManager.set_sfx_volume(original_sfx_volume, false)
		AudioManager.set_music_volume(original_music_volume, false)
	AudioManager.ensure_audio_state()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# Function for return button
func _on_return_button_pressed():
	print("Return button clicked! Returning to: ", previous_scene)
	# Handle unsaved changes to audio settings
	if AudioManager.master_volume != original_master_volume or \
	   AudioManager.sfx_volume != original_sfx_volume or \
	   AudioManager.music_volume != original_music_volume:
		AudioManager.set_master_volume(original_master_volume, false)
		AudioManager.set_sfx_volume(original_sfx_volume, false)
		AudioManager.set_music_volume(original_music_volume, false)
	AudioManager.ensure_audio_state()
	
	# Return to the previous scene
	get_tree().change_scene_to_file(previous_scene)

func _on_audio_button_pressed():
	print("Audio button pressed!")
	# Store current scene before changing to ensure we can return properly
	get_tree().set_meta("previous_scene", "res://Scenes/settings.tscn")
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")

func _on_video_button_pressed():
	print("Video button pressed!")
	# Store current scene before changing
	get_tree().set_meta("previous_scene", "res://Scenes/settings.tscn")
	get_tree().change_scene_to_file("res://Scenes/video_settings.tscn")

func _on_control_button_pressed():
	print("Control button pressed!")
	# Store current scene before changing
	get_tree().set_meta("previous_scene", "res://Scenes/settings.tscn")
	get_tree().change_scene_to_file("res://Scenes/control_settings.tscn")

func _on_button_hovered():
	ButtonHoverSound.play_hover_sound()

func _on_button_pressed():
	ButtonHoverSound.play_press_sound()
