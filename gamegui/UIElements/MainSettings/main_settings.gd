extends Control

@onready var master_slider = $CenterContainer/settingContainer/Control/resolution/VBoxContainer3/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HSlider
@onready var music_slider = $CenterContainer/settingContainer/Control/resolution/VBoxContainer3/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HSlider2
@onready var sfx_slider = $CenterContainer/settingContainer/Control/resolution/VBoxContainer3/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HSlider3
@onready var windowed_checkbox = $CenterContainer/settingContainer/Control/resolution/VBoxContainer3/HBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer2/CheckBox
@onready var fullscreen_checkbox = $CenterContainer/settingContainer/Control/resolution/VBoxContainer3/HBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer2/CheckBox2
@onready var resolution_dropdown = $CenterContainer/settingContainer/Control/resolution/VBoxContainer3/HBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer3/OptionButton
func _ready():
	# Set initial slider values based on current bus volumes
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))) * 100
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))) * 100
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))) * 100
	
	# Connect signals
	master_slider.value_changed.connect(_on_master_slider_changed)
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	
	# Connect signals
	windowed_checkbox.toggled.connect(_on_windowed_toggled)
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	
		# Populate dropdown
	for res in resolutions:
		resolution_dropdown.add_item("%dx%d" % [res.x, res.y])

	# Set initial value to default resolution
	var current_res = DisplayServer.window_get_size()
	var default_index = resolutions.find(current_res)
	if default_index != -1:
		resolution_dropdown.selected = default_index
	
	# Connect dropdown selection signal
	resolution_dropdown.item_selected.connect(_on_resolution_selected)

# Convert from linear scale (slider range 0-100) to decibels
func _on_master_slider_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100))

func _on_music_slider_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value / 100))

func _on_sfx_slider_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100))

func _on_windowed_toggled(button_pressed):
	if button_pressed:
		fullscreen_checkbox.button_pressed = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_fullscreen_toggled(button_pressed):
	if button_pressed:
		windowed_checkbox.button_pressed = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
func close_panel() -> void:
	print("exit settings")  # Print when the panel closes
	queue_free()  # Free the panel

# List of available resolutions (width, height)
var resolutions = [
	Vector2i(1280, 720),   # Default
	Vector2i(1600, 900),   # Higher option 1
	Vector2i(1920, 1080)   # Higher option 2
]


func _on_resolution_selected(index):
	# Set window resolution
	DisplayServer.window_set_size(resolutions[index])
	
	# Center the window
	var screen_size = DisplayServer.screen_get_size()  # Get screen size
	var window_size = DisplayServer.window_get_size()  # Get new window size
	DisplayServer.window_set_position((screen_size - window_size) / 2)  # Center window
