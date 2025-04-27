extends Control

# Corrected paths based on the node tree printout
@onready var resolution_option = $VBoxContainer/HBoxContainer/ResolutionOption
@onready var display_mode_option = $VBoxContainer/HBoxContainer2/DisplayModeOption
@onready var vsync_checkbox = $VBoxContainer/HBoxContainer3/VSyncCheckOption
@onready var refresh_rate_option = $VBoxContainer/HBoxContainer4/RefreshRateOption

# These are working correctly - keeping them as is
@onready var save_button = $CenterContainer/MapSettingPNG/popupMenu/baseMenu/NinePatchRect/MarginContainer/buttonContainer/topButtonContainer/SaveButton
@onready var exit_button = $CenterContainer/MapSettingPNG/popupMenu/baseMenu/NinePatchRect/MarginContainer/buttonContainer/topButtonContainer/ExitButton

# These are working correctly - keeping them as is
@onready var audio_tab = $CenterContainer/MapSettingPNG/Tab1
@onready var video_tab = $CenterContainer/MapSettingPNG/Tab2
@onready var control_tab = $CenterContainer/MapSettingPNG/Tab3

# Store original values
var original_resolution_index: int
var original_display_mode_index: int
var original_vsync: bool
var original_refresh_rate_index: int

# Available resolutions
var resolutions = [
	Vector2(1280, 720),
	Vector2(1920, 1080),
	Vector2(2560, 1440),
	Vector2(3840, 2160)
]

# Available refresh rates
var refresh_rates = [60, 75, 90, 120, 144, 165, 240]

func _ready():
	# Debug prints to check if nodes are found
	print("Resolution option node: ", resolution_option)
	print("Display mode option node: ", display_mode_option)
	print("VSync checkbox node: ", vsync_checkbox)
	print("Refresh rate option node: ", refresh_rate_option)
	print("Save button node: ", save_button)
	print("Exit button node: ", exit_button)
	print("Audio tab found: ", audio_tab != null)
	print("Video tab found: ", video_tab != null)
	print("Control tab found: ", control_tab != null)
	
	# Wait for nodes to initialize fully
	await get_tree().process_frame
	
	original_resolution_index = _get_current_resolution_index()
	original_display_mode_index = DisplayServer.window_get_mode()
	original_vsync = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
	original_refresh_rate_index = _get_current_refresh_rate_index()
	
	_setup_resolution_options()
	_setup_display_mode_options()
	_setup_refresh_rate_options()
	
	if resolution_option:
		resolution_option.selected = original_resolution_index
	if display_mode_option:
		display_mode_option.selected = original_display_mode_index
	if vsync_checkbox:
		vsync_checkbox.button_pressed = original_vsync
	if refresh_rate_option:
		refresh_rate_option.selected = original_refresh_rate_index
	
	if resolution_option:
		resolution_option.item_selected.connect(_on_resolution_selected)
	if display_mode_option:
		display_mode_option.item_selected.connect(_on_display_mode_selected)
	if vsync_checkbox:
		vsync_checkbox.toggled.connect(_on_vsync_toggled)
	if refresh_rate_option:
		refresh_rate_option.item_selected.connect(_on_refresh_rate_selected)
	
	if save_button:
		save_button.pressed.connect(_on_save_button_pressed)
		save_button.mouse_entered.connect(_on_button_hovered)
		save_button.pressed.connect(_on_button_pressed)
	
	if exit_button:
		exit_button.pressed.connect(_on_exit_button_pressed)
		exit_button.mouse_entered.connect(_on_button_hovered)
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

# --- Setup Functions ---
func _setup_resolution_options():
	if resolution_option:
		resolution_option.clear()
		resolution_option.add_item("1280x720 (720p)")
		resolution_option.add_item("1920x1080 (1080p)")
		resolution_option.add_item("2560x1440 (1440p)")
		resolution_option.add_item("3840x2160 (4K)")
	else:
		print("ERROR: resolution_option is null")

func _setup_display_mode_options():
	if display_mode_option:
		display_mode_option.clear()
		display_mode_option.add_item("Windowed")
		display_mode_option.add_item("Fullscreen")
		display_mode_option.add_item("Borderless Windowed")
	else:
		print("ERROR: display_mode_option is null")

func _setup_refresh_rate_options():
	if refresh_rate_option:
		refresh_rate_option.clear()
		for rate in refresh_rates:
			refresh_rate_option.add_item(str(rate) + " Hz")
	else:
		print("ERROR: refresh_rate_option is null")

# --- Getters ---
func _get_current_resolution_index() -> int:
	var current_size = DisplayServer.window_get_size()
	for i in range(resolutions.size()):
		if resolutions[i].is_equal_approx(current_size):
			return i
	return 1

func _get_current_refresh_rate_index() -> int:
	var current_rate = DisplayServer.screen_get_refresh_rate()
	for i in range(refresh_rates.size()):
		if refresh_rates[i] == current_rate:
			return i
	return 0

# --- Signal Handlers ---
func _on_resolution_selected(index):
	if index >= 0 and index < resolutions.size():
		DisplayServer.window_set_size(resolutions[index])
		var screen_size = DisplayServer.screen_get_size()
		var window_size = DisplayServer.window_get_size()
		var centered_position = (screen_size - window_size) / 2
		DisplayServer.window_set_position(centered_position)

func _on_display_mode_selected(index):
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func _on_vsync_toggled(toggled_on):
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED)

func _on_refresh_rate_selected(index):
	if index >= 0 and index < refresh_rates.size():
		print("Setting refresh rate to: " + str(refresh_rates[index]) + " Hz")

# --- Save and Exit ---
func _on_save_button_pressed():
	var config = ConfigFile.new()
	
	if resolution_option and display_mode_option and vsync_checkbox and refresh_rate_option:
		config.set_value("video", "resolution_index", resolution_option.selected)
		config.set_value("video", "display_mode_index", display_mode_option.selected)
		config.set_value("video", "vsync", vsync_checkbox.button_pressed)
		config.set_value("video", "refresh_rate_index", refresh_rate_option.selected)
		config.save("user://video_settings.cfg")
		
		original_resolution_index = resolution_option.selected
		original_display_mode_index = display_mode_option.selected
		original_vsync = vsync_checkbox.button_pressed
		original_refresh_rate_index = refresh_rate_option.selected
		
		print("Video settings saved!")
	else:
		print("Cannot save settings: Some UI elements are null")

func _on_exit_button_pressed():
	if resolution_option and display_mode_option and vsync_checkbox and refresh_rate_option:
		if resolution_option.selected != original_resolution_index or \
		   display_mode_option.selected != original_display_mode_index or \
		   vsync_checkbox.button_pressed != original_vsync or \
		   refresh_rate_option.selected != original_refresh_rate_index:
			
			_on_resolution_selected(original_resolution_index)
			_on_display_mode_selected(original_display_mode_index)
			_on_vsync_toggled(original_vsync)
			_on_refresh_rate_selected(original_refresh_rate_index)
	
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# --- Tab Handlers ---
func _on_audio_button_pressed():
	print("Audio button pressed!")
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")

func _on_video_button_pressed():
	print("Video button pressed!")
	get_tree().change_scene_to_file("res://Scenes/video_settings.tscn")

func _on_control_button_pressed():
	print("Control button pressed!")
	get_tree().change_scene_to_file("res://Scenes/control_settings.tscn")

# --- Hover and Press Sounds ---
func _on_button_hovered():
	ButtonHoverSound.play_hover_sound()

func _on_button_pressed():
	ButtonHoverSound.play_press_sound()
