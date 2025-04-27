extends Control

# Control UI elements within the CenterContainer
@onready var move_forward_button = $CenterContainer/MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer/Button
@onready var move_backward_button = $CenterContainer/MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer4/Button
@onready var move_left_button = $CenterContainer/MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer3/Button
@onready var move_right_button = $CenterContainer/MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer2/Button
@onready var invert_mouse_checkbox = $CenterContainer/MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer5/CheckBox
@onready var mouse_sensitivity_slider = $CenterContainer/MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer6/HSlider

# These are working correctly - keeping them as is
@onready var save_button = $CenterContainer/MapSettingPNG/popupMenu/baseMenu/NinePatchRect/MarginContainer/buttonContainer/topButtonContainer/SaveButton
@onready var exit_button = $CenterContainer/MapSettingPNG/popupMenu/baseMenu/NinePatchRect/MarginContainer/buttonContainer/topButtonContainer/ExitButton

# These are working correctly - keeping them as is
@onready var audio_tab = $CenterContainer/MapSettingPNG/Tab1
@onready var video_tab = $CenterContainer/MapSettingPNG/Tab2
@onready var control_tab = $CenterContainer/MapSettingPNG/Tab3

# Store original values
var original_mouse_inverted: bool
var original_mouse_sensitivity: float
var original_key_bindings = {}

func _ready():
	# Debug prints to check if nodes are found
	print("Move Forward button: ", move_forward_button)
	print("Move Backward button: ", move_backward_button)
	print("Move Left button: ", move_left_button)
	print("Move Right button: ", move_right_button)
	print("Invert Mouse checkbox: ", invert_mouse_checkbox)
	print("Mouse Sensitivity slider: ", mouse_sensitivity_slider)
	print("Save button node: ", save_button)
	print("Exit button node: ", exit_button)
	print("Audio tab found: ", audio_tab != null)
	print("Video tab found: ", video_tab != null)
	print("Control tab found: ", control_tab != null)
	
	# Wait for nodes to initialize fully
	await get_tree().process_frame
	
	# Load current control settings
	_load_control_settings()
	
	# Connect signals
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
		
	# Connect control-specific signals
	if invert_mouse_checkbox:
		invert_mouse_checkbox.toggled.connect(_on_invert_mouse_toggled)
	if mouse_sensitivity_slider:
		mouse_sensitivity_slider.value_changed.connect(_on_mouse_sensitivity_changed)
	
	# Connect key rebinding buttons
	if move_forward_button:
		move_forward_button.pressed.connect(_on_rebind_key_pressed.bind("move_forward"))
	if move_backward_button:
		move_backward_button.pressed.connect(_on_rebind_key_pressed.bind("move_backward"))
	if move_left_button:
		move_left_button.pressed.connect(_on_rebind_key_pressed.bind("move_left"))
	if move_right_button:
		move_right_button.pressed.connect(_on_rebind_key_pressed.bind("move_right"))

# --- Load Control Settings ---
func _load_control_settings():
	var config = ConfigFile.new()
	var err = config.load("user://control_settings.cfg")
	
	if err == OK:
		# Load saved control settings
		if invert_mouse_checkbox:
			var inverted = config.get_value("mouse", "inverted", false)
			invert_mouse_checkbox.button_pressed = inverted
			original_mouse_inverted = inverted
		
		if mouse_sensitivity_slider:
			var sensitivity = config.get_value("mouse", "sensitivity", 0.5)
			mouse_sensitivity_slider.value = sensitivity
			original_mouse_sensitivity = sensitivity
		
		# Load key bindings
		var forward_key = config.get_value("keys", "move_forward", KEY_W)
		var backward_key = config.get_value("keys", "move_backward", KEY_S)
		var left_key = config.get_value("keys", "move_left", KEY_A)
		var right_key = config.get_value("keys", "move_right", KEY_D)
		
		# Store original key bindings
		original_key_bindings = {
			"move_forward": forward_key,
			"move_backward": backward_key,
			"move_left": left_key,
			"move_right": right_key
		}
		
		# Update button labels
		_update_key_button_labels()
	else:
		# Set default values
		if invert_mouse_checkbox:
			invert_mouse_checkbox.button_pressed = false
			original_mouse_inverted = false
		
		if mouse_sensitivity_slider:
			mouse_sensitivity_slider.value = 0.5
			original_mouse_sensitivity = 0.5
		
		# Default key bindings
		original_key_bindings = {
			"move_forward": KEY_W,
			"move_backward": KEY_S,
			"move_left": KEY_A,
			"move_right": KEY_D
		}
		
		# Update button labels
		_update_key_button_labels()

# --- Update Key Button Labels ---
func _update_key_button_labels():
	if move_forward_button:
		move_forward_button.text = OS.get_keycode_string(original_key_bindings["move_forward"])
	if move_backward_button:
		move_backward_button.text = OS.get_keycode_string(original_key_bindings["move_backward"])
	if move_left_button:
		move_left_button.text = OS.get_keycode_string(original_key_bindings["move_left"])
	if move_right_button:
		move_right_button.text = OS.get_keycode_string(original_key_bindings["move_right"])

# --- Control-specific Signal Handlers ---
func _on_invert_mouse_toggled(toggled_on):
	print("Mouse inversion set to: ", toggled_on)

func _on_mouse_sensitivity_changed(value):
	print("Mouse sensitivity set to: ", value)

var _current_rebinding_action = ""

func _on_rebind_key_pressed(action):
	_current_rebinding_action = action
	print("Press any key to rebind '", action, "'...")
	
	# Change the button text to indicate waiting for input
	match action:
		"move_forward":
			if move_forward_button:
				move_forward_button.text = "Press any key..."
		"move_backward":
			if move_backward_button:
				move_backward_button.text = "Press any key..."
		"move_left":
			if move_left_button:
				move_left_button.text = "Press any key..."
		"move_right":
			if move_right_button:
				move_right_button.text = "Press any key..."
	
	# Enable input processing to catch the next key press
	set_process_input(true)

func _input(event):
	if _current_rebinding_action != "" and event is InputEventKey and event.pressed:
		# Assign the new key to the action
		original_key_bindings[_current_rebinding_action] = event.keycode
		
		# Update the button label
		match _current_rebinding_action:
			"move_forward":
				if move_forward_button:
					move_forward_button.text = OS.get_keycode_string(event.keycode)
			"move_backward":
				if move_backward_button:
					move_backward_button.text = OS.get_keycode_string(event.keycode)
			"move_left":
				if move_left_button:
					move_left_button.text = OS.get_keycode_string(event.keycode)
			"move_right":
				if move_right_button:
					move_right_button.text = OS.get_keycode_string(event.keycode)
		
		print("Action '", _current_rebinding_action, "' rebound to key: ", OS.get_keycode_string(event.keycode))
		
		# Reset rebinding state
		_current_rebinding_action = ""
		
		# Disable input processing
		set_process_input(false)
		
		# Consume the event
		get_viewport().set_input_as_handled()

# --- Save and Exit ---
func _on_save_button_pressed():
	var config = ConfigFile.new()
	
	if invert_mouse_checkbox and mouse_sensitivity_slider:
		# Save mouse settings
		config.set_value("mouse", "inverted", invert_mouse_checkbox.button_pressed)
		config.set_value("mouse", "sensitivity", mouse_sensitivity_slider.value)
		
		# Save key bindings
		config.set_value("keys", "move_forward", original_key_bindings["move_forward"])
		config.set_value("keys", "move_backward", original_key_bindings["move_backward"])
		config.set_value("keys", "move_left", original_key_bindings["move_left"])
		config.set_value("keys", "move_right", original_key_bindings["move_right"])
		
		config.save("user://control_settings.cfg")
		
		# Update original values
		original_mouse_inverted = invert_mouse_checkbox.button_pressed
		original_mouse_sensitivity = mouse_sensitivity_slider.value
		
		print("Control settings saved!")
	else:
		print("Cannot save settings: Some UI elements are null")

func _on_exit_button_pressed():
	if invert_mouse_checkbox and mouse_sensitivity_slider:
		# Check if any settings were changed
		if invert_mouse_checkbox.button_pressed != original_mouse_inverted or \
		   mouse_sensitivity_slider.value != original_mouse_sensitivity:
			
			# Revert to original values
			invert_mouse_checkbox.button_pressed = original_mouse_inverted
			mouse_sensitivity_slider.value = original_mouse_sensitivity
	
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
