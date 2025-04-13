@tool
extends Node2D

@export var cell_size : Vector2 = Vector2(64, 64)  # Default cell size (set in the inspector)
@export var grid_size : Vector2i = Vector2i(20, 15)  # Default number of cells (set in the inspector)
@onready var save_load: Control = $DesignerCamera/CanvasLayer/SaveLoad
@onready var designer_settings: Control = $DesignerCamera/CanvasLayer/DesignerSettings

@onready var grid_controls: Control = $DesignerCamera/CanvasLayer/gridControls
@onready var grid_display: GridDisplay = $GridDisplay
@onready var asset_library := (
	$DesignerCamera/CanvasLayer/accordion_menu/HorizontalMenu/MenuHolder/CollapsibleContainer/MarginContainer/VBoxContainer/SubMenu3/CollapsibleContainer/MarginContainer/AssetLibrary
) as AssetLibrary
var dragging_scene: Node2D = null
var scene_being_dragged: PackedScene = null

signal button_pressed(button_name: String)

func _ready():
	# Connect the button signal
	connect("button_pressed", Callable(self, "handle_button_press"))
	if asset_library.has_signal("asset_selected"):
		print("Connecting signal")
		asset_library.connect("asset_selected", Callable(self, "_on_asset_selected"))
	else:
		print("Signal not found!")
	# Ensure grid_controls starts hidden
	grid_controls.visible = false
	save_load.visible = false
	designer_settings.visible = false
	# Apply initial settings from the inspector
	apply_grid_settings()

func apply_grid_settings():
	# Apply the preset grid size (instead of calculating it dynamically)
	if grid_display:
		grid_display.grid_size = grid_size
		grid_display.cell_size = cell_size  # Ensure the cell size is applied

# Example function to update cell size
func update_cell_size(new_size: Vector2):
	if grid_display:
		grid_display.cell_size = new_size

# Example function to toggle grid visibility
func toggle_grid():
	if grid_display:
		grid_display.draw_grid = !grid_display.draw_grid

# Example function to toggle border
func toggle_border():
	if grid_display:
		grid_display.draw_border = !grid_display.draw_border

# Handle button presses
func handle_button_press(button_name: String):
	match button_name:
		"grid_controls":
			grid_controls.visible = !grid_controls.visible  # Toggle visibility
		"designer_settings":
			designer_settings.visible = true
		"save_load":
			save_load.visible = true
			
# Called when the dropdown (OptionButton) changes (Cell Size)
func set_cell_size(index: int):
	# Get the selected cell size from the OptionButton
	var cell_size = int($DesignerCamera/CanvasLayer/gridControls/CenterContainer/VBoxContainer/OptionButton.get_item_text(index))  # Get the text of the selected item and convert it to an integer

	# Update the grid's cell size based on the selected option
	grid_display.cell_size = Vector2(cell_size, cell_size)

func set_line_and_border_width(value: float):
	# Ensure the value is within 1 to 5 range
	value = clamp(value, 1, 5)  # Clamps the value between 1 and 5
	grid_display.line_size = Vector2(value, value)
	grid_display.border_width = value

# Closes the UI panel
func close_ui():
	grid_controls.hide()


func _on_check_box_toggled(toggled_on: bool) -> void:
	grid_display.draw_grid = toggled_on

func _on_asset_selected(scene_path: String):
	scene_being_dragged = load(scene_path) as PackedScene
	dragging_scene = scene_being_dragged.instantiate() as Node2D
	add_child(dragging_scene) # Not final placement yet

func _process(delta: float) -> void:
	if dragging_scene:
		dragging_scene.global_position = get_global_mouse_position()
		
func _unhandled_input(event: InputEvent) -> void:
	if dragging_scene and event is InputEventMouseButton and not event.pressed:
		# Optionally snap to grid here
		dragging_scene = null
		scene_being_dragged = null

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # "Esc" key by default
		# Hide and delete the panels when Esc is pressed
		if grid_controls and grid_controls.visible:
			grid_controls.visible = false
		if save_load and save_load.visible:
			save_load.visible = false
		if designer_settings and designer_settings.visible:
			designer_settings.visible = false
