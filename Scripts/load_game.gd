extends Control

func _ready():
	# Connect return button
	$ReturnButton.pressed.connect(_on_ReturnButton_pressed)
	
	# Remove separator lines between save slots
	$VBoxContainer.add_theme_constant_override("separation", 0)
	
	# Connect hover effects for all save slots
	for i in range(1, 5):  # For buttons 1-4
		var button = get_node("VBoxContainer/SaveSlot" + str(i))
		if button:
			button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
			button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
			
			# Remove borders from button styles
			_remove_button_borders(button)

func _on_ReturnButton_pressed():
	print("Return button clicked!")
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_button_mouse_entered(button):
	# Create hover effect without borders
	var tween = create_tween()
	tween.tween_property(button, "modulate", Color(1.2, 1.2, 1.2), 0.2)  # Lighten

func _on_button_mouse_exited(button):
	# Return to normal
	var tween = create_tween()
	tween.tween_property(button, "modulate", Color(1, 1, 1), 0.2)  # Normal

func _remove_button_borders(button):
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
