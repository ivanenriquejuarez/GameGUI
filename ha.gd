extends Control
# References to UI elements
@onready var master_slider = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/MasterSlider
@onready var sfx_slider = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/SFXSlider
@onready var music_slider = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/MusicSlider
@onready var save_button = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/MarginContainer/buttonContainer/topButtonContainer/SaveButton
@onready var exit_button = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/MarginContainer/buttonContainer/topButtonContainer/ExitButton

# Update these paths to match the exact node structure from your screenshot
@onready var audio_tab = $MapSettingPNG/Tab1
@onready var video_tab = $MapSettingPNG/Tab2
@onready var control_tab = $MapSettingPNG/Tab3

# Store original values
var original_master_volume: float
var original_sfx_volume: float
var original_music_volume: float

func _ready():
	# Print debug info to check if nodes are being found
	print("Audio tab found: ", audio_tab != null)
	print("Video tab found: ", video_tab != null)
	print("Control tab found: ", control_tab != null)
	
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
	
	# Connect signals for audio settings
	master_slider.value_changed.connect(_on_master_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	save_button.pressed.connect(_on_save_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	save_button.mouse_entered.connect(_on_button_hovered)
	exit_button.mouse_entered.connect(_on_button_hovered)
	save_button.pressed.connect(_on_button_pressed)
	exit_button.pressed.connect(_on_button_pressed)
	
	# Connect signals for tab buttons
	if audio_tab:
		audio_tab.pressed.connect(_on_audio_button_pressed)
		audio_tab.mouse_entered.connect(_on_button_hovered)
	if video_tab:
		video_tab.pressed.connect(_on_video_button_pressed)
		video_tab.mouse_entered.connect(_on_button_hovered)
	if control_tab:
		control_tab.pressed.connect(_on_control_button_pressed)
		control_tab.mouse_entered.connect(_on_button_hovered)

# Volume change handlers
func _on_master_slider_value_changed(value):
	AudioManager.set_master_volume(value, false)

func _on_sfx_slider_value_changed(value):
	AudioManager.set_sfx_volume(value, false)

func _on_music_slider_value_changed(value):
	AudioManager.set_music_volume(value, false)

# Save volume settings
func _on_save_button_pressed():
	AudioManager.save_volume_settings()
	original_master_volume = AudioManager.master_volume
	original_sfx_volume = AudioManager.sfx_volume
	original_music_volume = AudioManager.music_volume
	print("Settings saved!")

# Return/exit button
func _on_exit_button_pressed():
	# Revert unsaved settings
	if AudioManager.master_volume != original_master_volume or \
	   AudioManager.sfx_volume != original_sfx_volume or \
	   AudioManager.music_volume != original_music_volume:
		AudioManager.set_master_volume(original_master_volume, false)
		AudioManager.set_sfx_volume(original_sfx_volume, false)
		AudioManager.set_music_volume(original_music_volume, false)
	AudioManager.ensure_audio_state()
	# 🌟 Check this scene path is correct
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# Tab navigation functions with debug prints
func _on_audio_button_pressed():
	print("Audio button pressed!")
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")
	
func _on_video_button_pressed():
	print("Video button pressed!")
	get_tree().change_scene_to_file("res://Scenes/video_settings.tscn")
	
func _on_control_button_pressed():
	print("Control button pressed!")
	get_tree().change_scene_to_file("res://Scenes/control_settings.tscn")

# Hover & press sounds
func _on_button_hovered():
	ButtonHoverSound.play_hover_sound()

func _on_button_pressed():
	ButtonHoverSound.play_press_sound()
