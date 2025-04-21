extends Control

# References to UI elements - updated paths to match your scene structure
@onready var resolution_option = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer/ResolutionOption
@onready var display_mode_option = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer2/DisplayModeOption
@onready var vsync_checkbox = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer3/VSyncCheckOption
@onready var refresh_rate_option = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer4/RefreshRateOption
@onready var save_button = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/MarginContainer/buttonContainer/topButtonContainer/SaveButton
@onready var exit_button = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/MarginContainer/buttonContainer/topButtonContainer/ExitButton

# References to tab buttons
@onready var audio_tab = $MapSettingPNG/Tab1
@onready var video_tab = $MapSettingPNG/Tab2
@onready var control_tab = $MapSettingPNG/Tab3

# Store original values
var original_resolution_index: int
var original_display_mode_index: int
var original_vsync: bool
var original_refresh_rate_index: int

# Available resolutions
var resolutions = [
	Vector2(1280, 720),  # 720p
	Vector2(1920, 1080), # 1080p/Full HD
	Vector2(2560, 1440), # 1440p/QHD
	Vector2(3840, 2160)  # 2160p/4K
]

# Available refresh rates
var refresh_rates = [60, 75, 90, 120, 144, 165, 240]

func _ready():
	# Print debug info to check if nodes are being found
	print("Audio tab found: ", audio_tab != null)
	print("Video tab found: ", video_tab != null)
	print("Control tab found: ", control_tab != null)
	
	# Save original video settings
	original_resolution_index = _get_current_resolution_index()
	original_display_mode_index = DisplayServer.window_get_mode()
	original_vsync = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
	original_refresh_rate_index = _get_current_refresh_rate_index()
	
	# Setup UI elements
	_setup_resolution_options()
	_setup_display_mode_options()
	_setup_refresh_rate_options()
	
	resolution_option.selected = original_resolution_index
	display_mode_option.selected = original_display_mode_index
	vsync_checkbox.button_pressed = original_vsync
	refresh_rate_option.selected = original_refresh_rate_index
	
	# Connect signals for video settings
	resolution_option.item_selected.connect(_on_resolution_selected)
	display_mode_option.item_selected.connect(_on_display_mode_selected)
	vsync_checkbox.toggled.connect(_on_vsync_toggled)
	refresh_rate_option.item_selected.connect(_on_refresh_rate_selected)
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

func _setup_resolution_options():
	resolution_option.clear()
	resolution_option.add_item("1280x720 (720p)")
	resolution_option.add_item("1920x1080 (1080p)")
	resolution_option.add_item("2560x1440 (1440p)")
	resolution_option.add_item("3840x2160 (4K)")

func _setup_display_mode_options():
	display_mode_option.clear()
	display_mode_option.add_item("Windowed")
	display_mode_option.add_item("Fullscreen")
	display_mode_option.add_item("Borderless Windowed")

func _setup_refresh_rate_options():
	refresh_rate_option.clear()
	for rate in refresh_rates:
		refresh_rate_option.add_item(str(rate) + " Hz")

func _get_current_resolution_index() -> int:
	var current_size = DisplayServer.window_get_size()
	for i in range(resolutions.size()):
		if resolutions[i].is_equal_approx(current_size):
			return i
	return 1  # Default to 1080p if not found

func _get_current_refresh_rate_index() -> int:
	var current_rate = DisplayServer.screen_get_refresh_rate()
	for i in range(refresh_rates.size()):
		if refresh_rates[i] == current_rate:
			return i
	return 0  # Default to 60Hz if not found

# Setting handlers
func _on_resolution_selected(index):
	if index >= 0 and index < resolutions.size():
		DisplayServer.window_set_size(resolutions[index])
		# Center the window after changing resolution
		var screen_size = DisplayServer.screen_get_size()
		var window_size = DisplayServer.window_get_size()
		var centered_position = (screen_size - window_size) / 2
		DisplayServer.window_set_position(centered_position)

func _on_display_mode_selected(index):
	match index:
		0: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2: # Borderless Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func _on_vsync_toggled(toggled_on):
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED)

func _on_refresh_rate_selected(index):
	if index >= 0 and index < refresh_rates.size():
		print("Setting refresh rate to: " + str(refresh_rates[index]) + " Hz")
		# Note: Some systems may not support changing refresh rate via code

# Save video settings
func _on_save_button_pressed():
	# Save video settings to config file
	var config = ConfigFile.new()
	config.set_value("video", "resolution_index", resolution_option.selected)
	config.set_value("video", "display_mode_index", display_mode_option.selected)
	config.set_value("video", "vsync", vsync_checkbox.button_pressed)
	config.set_value("video", "refresh_rate_index", refresh_rate_option.selected)
	config.save("user://video_settings.cfg")
	
	# Update original values
	original_resolution_index = resolution_option.selected
	original_display_mode_index = display_mode_option.selected
	original_vsync = vsync_checkbox.button_pressed
	original_refresh_rate_index = refresh_rate_option.selected
	
	print("Video settings saved!")

# Return/exit button
func _on_exit_button_pressed():
	# Revert unsaved settings
	if resolution_option.selected != original_resolution_index or \
	   display_mode_option.selected != original_display_mode_index or \
	   vsync_checkbox.button_pressed != original_vsync or \
	   refresh_rate_option.selected != original_refresh_rate_index:
		
		_on_resolution_selected(original_resolution_index)
		_on_display_mode_selected(original_display_mode_index)
		_on_vsync_toggled(original_vsync)
		_on_refresh_rate_selected(original_refresh_rate_index)
	
	# Return to main menu
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
