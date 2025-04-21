extends Control

# References to UI elements
@onready var save_button = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/MarginContainer/buttonContainer/topButtonContainer/SaveButton
@onready var exit_button = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/MarginContainer/buttonContainer/topButtonContainer/ExitButton

# References to movement control buttons
@onready var move_forward_button = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer/Button
@onready var move_backward_button = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer4/Button
@onready var move_left_button = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer3/Button
@onready var move_right_button = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer2/Button

# References to mouse settings
@onready var invert_mouse_checkbox = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer5/CheckBox
@onready var mouse_sensitivity_node = $MapSettingPNG/popupMenu/baseMenu/NinePatchRect/VBoxContainer/HBoxContainer6/MouseSensitivity

# References to tab buttons
@onready var audio_tab = $MapSettingPNG/Tab1
@onready var video_tab = $MapSettingPNG/Tab2
@onready var control_tab = $MapSettingPNG/Tab3

# Mapping of action names to buttons and user-friendly names
var action_buttons = {
	"move_forward": {"button": null, "name": "Move Forward"},
	"move_backward": {"button": null, "name": "Move Backward"},
	"move_left": {"button": null, "name": "Move Left"},
	"move_right": {"button": null, "name": "Move Right"}
}

# Store original mappings
var original_mappings = {}
var original_invert_mouse = false
var original_mouse_sensitivity = 1.0
var current_mapping_button = null

func _ready():
	# Debug to check which references are found
	print("Move Forward button found: ", move_forward_button != null)
	print("Move Backward button found: ", move_backward_button != null)
	print("Move Left button found: ", move_left_button != null)
	print("Move Right button found: ", move_right_button != null)
	print("Invert Mouse checkbox found: ", invert_mouse_checkbox != null)
	print("Mouse Sensitivity node found: ", mouse_sensitivity_node != null)
	
	# Initialize button references
	action_buttons["move_forward"].button = move_forward_button
	action_buttons["move_backward"].button = move_backward_button
	action_buttons["move_left"].button = move_left_button
	action_buttons["move_right"].button = move_right_button
	
	# Save original mappings
	_save_original_mappings()
	
	# Set checkbox value if it exists
	if invert_mouse_checkbox:
		original_invert_mouse = invert_mouse_checkbox.button_pressed
		invert_mouse_checkbox.toggled.connect(_on_invert_mouse_toggled)
	
	# Set slider value if it exists and is a slider
	if mouse_sensitivity_node and mouse_sensitivity_node is HSlider:
		original_mouse_sensitivity = mouse_sensitivity_node.value
		mouse_sensitivity_node.value_changed.connect(_on_mouse_sensitivity_changed)
	
	# Initialize button text and connect signals
	for action in action_buttons.keys():
		var button = action_buttons[action].button
		if button:
			button.text = _get_key_name(action)
			button.pressed.connect(_on_key_button_pressed.bind(button, action))
	
	# Connect other signals
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

func _save_original_mappings():
	for action in action_buttons.keys():
		original_mappings[action] = []
		if InputMap.has_action(action):
			for event in InputMap.action_get_events(action):
				if event is InputEventKey:
					original_mappings[action].append(event.physical_keycode)

func _get_key_name(action):
	if not InputMap.has_action(action):
		return "Unassigned"
		
	var events = InputMap.action_get_events(action)
	if events.size() > 0:
		for event in events:
			if event is InputEventKey:
				return OS.get_keycode_string(event.physical_keycode)
	return "Unassigned"

func _on_key_button_pressed(button, action):
	# Highlight the button being mapped
	if current_mapping_button:
		current_mapping_button.text = _get_key_name(current_mapping_button.get_meta("action"))
	
	current_mapping_button = button
	current_mapping_button.set_meta("action", action)
	current_mapping_button.text = "Press any key..."

func _input(event):
	if current_mapping_button and event is InputEventKey and event.pressed:
		var action = current_mapping_button.get_meta("action")
		
		# Check if this key is already assigned
		for existing_action in action_buttons.keys():
			if existing_action != action and InputMap.has_action(existing_action):
				for existing_event in InputMap.action_get_events(existing_action):
					if existing_event is InputEventKey and existing_event.physical_keycode == event.physical_keycode:
						# Remove the key from the other action
						InputMap.action_erase_event(existing_action, existing_event)
						# Update UI for the other action
						if action_buttons[existing_action].button:
							action_buttons[existing_action].button.text = _get_key_name(existing_action)
						break
		
		# Make sure the action exists in the InputMap
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			
		# Clear existing events
		InputMap.action_erase_events(action)
		
		# Add new event
		InputMap.action_add_event(action, event)
		
		# Update button text
		current_mapping_button.text = OS.get_keycode_string(event.physical_keycode)
		current_mapping_button = null
		
		# Consume the event
		get_viewport().set_input_as_handled()

# Mouse settings handlers
func _on_invert_mouse_toggled(toggled_on):
	print("Mouse inversion " + ("enabled" if toggled_on else "disabled"))

func _on_mouse_sensitivity_changed(value):
	print("Mouse sensitivity set to: " + str(value))

# Save control settings
func _on_save_button_pressed():
	# Save key bindings
	var key_config = ConfigFile.new()
	
	for action in action_buttons.keys():
		if InputMap.has_action(action):
			var events = InputMap.action_get_events(action)
			var keycodes = []
			
			for event in events:
				if event is InputEventKey:
					keycodes.append(event.physical_keycode)
			
			key_config.set_value("controls", action, keycodes)
	
	key_config.save("user://key_bindings.cfg")
	
	# Save mouse settings if components exist
	if invert_mouse_checkbox or (mouse_sensitivity_node and mouse_sensitivity_node is HSlider):
		var mouse_config = ConfigFile.new()
		
		if invert_mouse_checkbox:
			mouse_config.set_value("mouse", "invert_y", invert_mouse_checkbox.button_pressed)
		
		if mouse_sensitivity_node and mouse_sensitivity_node is HSlider:
			mouse_config.set_value("mouse", "sensitivity", mouse_sensitivity_node.value)
		
		mouse_config.save("user://mouse_settings.cfg")
	
	# Update original values
	_save_original_mappings()
	if invert_mouse_checkbox:
		original_invert_mouse = invert_mouse_checkbox.button_pressed
	if mouse_sensitivity_node and mouse_sensitivity_node is HSlider:
		original_mouse_sensitivity = mouse_sensitivity_node.value
	
	print("Control settings saved!")

# Return/exit button
func _on_exit_button_pressed():
	# Revert unsaved key bindings
	for action in original_mappings.keys():
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
			
			for keycode in original_mappings[action]:
				var event = InputEventKey.new()
				event.physical_keycode = keycode
				InputMap.action_add_event(action, event)
	
	# Revert unsaved mouse settings
	if invert_mouse_checkbox and invert_mouse_checkbox.button_pressed != original_invert_mouse:
		invert_mouse_checkbox.button_pressed = original_invert_mouse
		_on_invert_mouse_toggled(original_invert_mouse)
		
	if mouse_sensitivity_node and mouse_sensitivity_node is HSlider and mouse_sensitivity_node.value != original_mouse_sensitivity:
		mouse_sensitivity_node.value = original_mouse_sensitivity
		_on_mouse_sensitivity_changed(original_mouse_sensitivity)
	
	# Return to main menu
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# Tab navigation functions
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
