extends Control

# References to your UI elements in the scene tree
@onready var master_slider = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/MasterSlider
@onready var sfx_slider = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/SFXSlider
@onready var music_slider = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/MusicSlider
@onready var save_button = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/MarginContainer/buttonContainer/topButtonContainer/SaveButton
@onready var exit_button = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/MarginContainer/buttonContainer/topButtonContainer/ExitButton

# Store original values to revert if not saved
var original_master_volume: float
var original_sfx_volume: float
var original_music_volume: float

func _ready():
	# Store original values
	original_master_volume = AudioManager.master_volume
	original_sfx_volume = AudioManager.sfx_volume
	original_music_volume = AudioManager.music_volume

	# Set up slider values
	master_slider.min_value = 0
	master_slider.max_value = 100
	sfx_slider.min_value = 0
	sfx_slider.max_value = 100
	music_slider.min_value = 0
	music_slider.max_value = 100

	master_slider.value = AudioManager.master_volume
	sfx_slider.value = AudioManager.sfx_volume
	music_slider.value = AudioManager.music_volume

	# Connect signals
	master_slider.value_changed.connect(_on_master_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	save_button.pressed.connect(_on_save_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

	save_button.pressed.connect(_on_save_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

	# 🎯 Add hover sound connections
	save_button.mouse_entered.connect(_on_button_hovered)
	exit_button.mouse_entered.connect(_on_button_hovered)

	# 🔊 Add press sound connections
	save_button.pressed.connect(_on_button_pressed)
	exit_button.pressed.connect(_on_button_pressed)

# Slider change handlers - apply changes without saving
func _on_master_slider_value_changed(value):
	AudioManager.set_master_volume(value, false)  # false = don't save

func _on_sfx_slider_value_changed(value):
	AudioManager.set_sfx_volume(value, false)  # false = don't save

func _on_music_slider_value_changed(value):
	AudioManager.set_music_volume(value, false)  # false = don't save

# Save button - explicitly save settings
func _on_save_button_pressed():
	AudioManager.save_volume_settings()
	
	# Update original values since we've now saved
	original_master_volume = AudioManager.master_volume
	original_sfx_volume = AudioManager.sfx_volume
	original_music_volume = AudioManager.music_volume
	
	print("Settings saved!")

# Exit button - revert to original settings if not saved
func _on_exit_button_pressed():
	# Revert to original values if they were changed but not saved
	if AudioManager.master_volume != original_master_volume or \
	   AudioManager.sfx_volume != original_sfx_volume or \
	   AudioManager.music_volume != original_music_volume:
		
		# Revert to original values WITHOUT saving
		AudioManager.set_master_volume(original_master_volume, false)
		AudioManager.set_sfx_volume(original_sfx_volume, false)
		AudioManager.set_music_volume(original_music_volume, false)
	
	# Ensure audio state is consistent before changing scene
	AudioManager.ensure_audio_state()
	
	# Return to the previous menu
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
func _on_button_hovered():
	ButtonHoverSound.play_hover_sound()
	
func _on_button_pressed():
	ButtonHoverSound.play_press_sound()
