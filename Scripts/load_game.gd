extends Control

# Path to your saves folder
const SAVE_DIR = "res://saves/"

# Reference to overlay for fade effect
var overlay: ColorRect

func _ready():
	# Connect return button
	$ReturnButton.pressed.connect(_on_ReturnButton_pressed)
	
	# Remove separator lines between save slots
	$VBoxContainer.add_theme_constant_override("separation", 0)
	
	# Create an overlay for fading effect
	create_overlay()
	
	# Hide the confirmation dialog at start
	$NinePatchRect.visible = false
	overlay.visible = false
	
	# Connect button signals for the confirmation dialog
	$NinePatchRect/yes.pressed.connect(_on_yes_pressed)
	$NinePatchRect/no.pressed.connect(_on_no_pressed)
	
	# Connect hover effects for all save slots
	for i in range(1, 5):  # For buttons 1-4
		var button = get_node("VBoxContainer/SaveSlot" + str(i))
		if button:
			button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
			button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
			button.pressed.connect(_on_save_slot_pressed.bind(i))
			
			# Remove borders from button styles
			remove_button_borders(button)
	
	# Ensure slots are in the correct order
	rearrange_slots()
	
	# Load and display save data
	load_save_data()

# Create an overlay for fade effect
func create_overlay():
	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)  # Start fully transparent
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block mouse events
	
	# Make overlay fill the entire screen
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.size_flags_horizontal = SIZE_FILL
	overlay.size_flags_vertical = SIZE_FILL
	
	# Ensure overlay is behind dialog but above everything else
	overlay.z_index = -1
	
	add_child(overlay)

# Function to ensure slots are in numerical order
func rearrange_slots():
	var vbox = $VBoxContainer
	
	# Create array of slots in correct order
	var ordered_slots = []
	for i in range(1, 5):
		ordered_slots.append(get_node("VBoxContainer/SaveSlot" + str(i)))
	
	# Remove all slots from container
	for slot in ordered_slots:
		vbox.remove_child(slot)
	
	# Add them back in numerical order
	for i in range(4):
		vbox.add_child(ordered_slots[i])

# Function to load save files and display them in slots
func load_save_data():
	# Get all save files from the directory
	var dir = DirAccess.open(SAVE_DIR)
	var save_files = []
	var file_timestamps = {}
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		# Collect all JSON files
		while file_name != "":
			if file_name.ends_with(".json"):
				save_files.append(file_name)
				
				# Try to read timestamp from the save file
				var filepath = SAVE_DIR + file_name
				if FileAccess.file_exists(filepath):
					var file = FileAccess.open(filepath, FileAccess.READ)
					var json_string = file.get_as_text()
					file.close()
					
					# Try to parse JSON and extract timestamp
					var json = JSON.new()
					var parse_result = json.parse(json_string)
					
					if parse_result == OK:
						var data = json.get_data()
						if data is Dictionary and data.has("timestamp"):
							# Convert full timestamp to just "Month Day" format
							var timestamp = data["timestamp"]
							var datetime_parts = timestamp.split(" ")[0].split("-")
							if datetime_parts.size() >= 3:
								var month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
												 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
								var month = int(datetime_parts[1])
								var day = int(datetime_parts[2])
								
								if month >= 1 and month <= 12:
									file_timestamps[file_name] = month_names[month-1] + " " + str(day)
								else:
									file_timestamps[file_name] = "Unknown"
							else:
								file_timestamps[file_name] = "Unknown"
						else:
							# Use current system time in Month Day format
							var datetime = Time.get_datetime_dict_from_system()
							var month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
											 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
							file_timestamps[file_name] = month_names[datetime.month-1] + " " + str(datetime.day)
					else:
						# Use current system time in Month Day format
						var datetime = Time.get_datetime_dict_from_system()
						var month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
										 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
						file_timestamps[file_name] = month_names[datetime.month-1] + " " + str(datetime.day)
				
			file_name = dir.get_next()
		
		# Sort save files alphabetically
		save_files.sort()
	
	# Update all slots in numerical order
	for i in range(1, 5):
		var index = i - 1
		var slot_button = get_node("VBoxContainer/SaveSlot" + str(i))
		var slot_label = slot_button.get_node("Label")
		
		if index < save_files.size():
			# This slot has a save file
			var save_name = save_files[index].get_basename()
			var timestamp = file_timestamps.get(save_files[index], "")
			
			# Update the slot with save name and timestamp
			slot_label.text = "Save Slot " + str(i) + " | " + save_name
			if timestamp != "":
				slot_label.text += " | " + timestamp
			
			# Store the save file name in the button for later use
			slot_button.set_meta("save_file", save_files[index])
		else:
			# Empty slot
			slot_label.text = "Save Slot " + str(i) + " | Empty"
			slot_button.set_meta("save_file", "")

# Store the current selected save file
var current_save_file = ""

# Handler for save slot button press
func _on_save_slot_pressed(slot_number):
	var button = get_node("VBoxContainer/SaveSlot" + str(slot_number))
	var save_file = button.get_meta("save_file")
	
	if save_file != "":
		# Save exists, fade in the overlay and show dialog
		current_save_file = save_file
		show_dialog_with_fade()
	else:
		print("No save in slot " + str(slot_number))

# Show dialog with fade effect
func show_dialog_with_fade():
	# Make overlay visible
	overlay.visible = true
	
	# Fade in the overlay
	var tween = create_tween()
	tween.tween_property(overlay, "color", Color(0, 0, 0, 0.7), 0.3)
	
	# Show the dialog after overlay fade
	tween.tween_callback(func():
		$NinePatchRect.visible = true
		$NinePatchRect.modulate = Color(1, 1, 1, 0)
		
		# Fade in the dialog
		var dialog_tween = create_tween()
		dialog_tween.tween_property($NinePatchRect, "modulate", Color(1, 1, 1, 1), 0.2)
	)

# Hide dialog with fade effect
func hide_dialog_with_fade():
	# Fade out the dialog
	var dialog_tween = create_tween()
	dialog_tween.tween_property($NinePatchRect, "modulate", Color(1, 1, 1, 0), 0.2)
	
	# After dialog fade, hide it and fade out overlay
	dialog_tween.tween_callback(func():
		$NinePatchRect.visible = false
		
		# Fade out the overlay
		var overlay_tween = create_tween()
		overlay_tween.tween_property(overlay, "color", Color(0, 0, 0, 0), 0.3)
		
		# After overlay fade, hide it
		overlay_tween.tween_callback(func():
			overlay.visible = false
		)
	)

# Handler for "Yes" button on the confirmation dialog
func _on_yes_pressed():
	if current_save_file != "":
		print("Loading game from file: " + current_save_file)
		
		# Fade out dialog with a faster transition
		var tween = create_tween()
		tween.tween_property($NinePatchRect, "modulate", Color(1, 1, 1, 0), 0.15)
		tween.parallel().tween_property(overlay, "color", Color(0, 0, 0, 1), 0.3)
		
		# After full fade to black, change scene
		tween.tween_callback(func():
			var save_path = SAVE_DIR + current_save_file
			get_tree().change_scene_to_file("res://Scenes/Designer/Designer.tscn")
			
			# Schedule loading of the save file after scene change
			call_deferred("_load_after_scene_change", save_path)
		)

# Handler for "No" button on the confirmation dialog
func _on_no_pressed():
	# Hide dialog with fade effect
	hide_dialog_with_fade()
	current_save_file = ""

# Function to load the save file after scene change
func _load_after_scene_change(save_path):
	DesignerState.load_from_file(save_path)

# Return button handler
func _on_ReturnButton_pressed():
	print("Return button clicked!")
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_button_mouse_entered(button):
	var tween = create_tween()
	tween.tween_property(button, "modulate", Color(1.2, 1.2, 1.2), 0.2)

func _on_button_mouse_exited(button):
	var tween = create_tween()
	tween.tween_property(button, "modulate", Color(1, 1, 1), 0.2)

func remove_button_borders(button):
	# Get the current styles
	var normal_style = button.get_theme_stylebox("normal")
	var hover_style = button.get_theme_stylebox("hover") 
	var pressed_style = button.get_theme_stylebox("pressed")
	
	# Make sure we're working with StyleBoxFlat
	if normal_style is StyleBoxFlat:
		normal_style.border_width_top = 0
		normal_style.border_width_bottom = 0
		normal_style.border_width_left = 0
		normal_style.border_width_right = 0
	
	if hover_style is StyleBoxFlat:
		hover_style.border_width_top = 0
		hover_style.border_width_bottom = 0
		hover_style.border_width_left = 0
		hover_style.border_width_right = 0
	
	if pressed_style is StyleBoxFlat:
		pressed_style.border_width_top = 0
		pressed_style.border_width_bottom = 0
		pressed_style.border_width_left = 0
		pressed_style.border_width_right = 0
