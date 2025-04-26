@tool
extends Node2D

@onready var canvas_layer: CanvasLayer = $DesignerCamera/CanvasLayer
@onready var designer_camera: Camera2D = $DesignerCamera

@onready var save_load = $DesignerCamera/CanvasLayer/SaveLoad
@onready var designer_settings = $DesignerCamera/CanvasLayer/DesignerSettings
@onready var grid_controls = $DesignerCamera/CanvasLayer/gridControls
@onready var grid_display: GridDisplay = $GridDisplay
@onready var asset_library := (
	$DesignerCamera/CanvasLayer/accordion_menu/HorizontalMenu/MenuHolder/CollapsibleContainer/MarginContainer/VBoxContainer/SubMenu3/CollapsibleContainer/MarginContainer/AssetLibrary
) as AssetLibrary
var grid_snap_enabled: bool = true
signal button_pressed(button_name: String)

func _ready():
	connect("button_pressed", Callable(self, "_on_button_pressed"))
	if asset_library.has_signal("asset_selected"):
		asset_library.connect("asset_selected", Callable(self, "_on_asset_selected"))
	grid_controls.visible = false
	save_load.visible = false
	designer_settings.visible = false
	apply_grid_settings()
	reload_designer_objects()

func apply_grid_settings():
	if Engine.is_editor_hint():
		return
	
	if grid_display:
		grid_display.grid_size = DesignerState.grid_size
		grid_display.cell_size = DesignerState.cell_size

func set_cell_size(index: int):
	var cell_size = int($DesignerCamera/CanvasLayer/gridControls/CenterContainer/VBoxContainer/OptionButton.get_item_text(index))
	grid_display.cell_size = Vector2(cell_size, cell_size)
	DesignerState.cell_size = Vector2(cell_size, cell_size)

func set_line_and_border_width(value: float):
	value = clamp(value, 1, 5)
	grid_display.line_size = Vector2(value, value)
	grid_display.border_width = value

func toggle_grid(toggled_on: bool):
	if grid_display:
		grid_display.visible = toggled_on

func toggle_grid_snap(toggled_on: bool):
	DesignerState.grid_snap_enabled = toggled_on
	
func _on_exit_pressed() -> void:
	grid_controls.visible = false
	
func snap_to_grid(pos: Vector2) -> Vector2:
	if not DesignerState.grid_snap_enabled:
		return pos

	var size = DesignerState.cell_size
	return Vector2(
		floor(pos.x / size.x) * size.x + size.x / 2,
		floor(pos.y / size.y) * size.y + size.y / 2
	)
	
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return  # Don’t run this in the editor
		
	if is_instance_valid(DesignerState.dragging_scene):
		var mouse_pos := get_viewport().get_camera_2d().get_global_mouse_position()
		DesignerState.dragging_scene.global_position = snap_to_grid(mouse_pos)
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if DesignerState.dragging_scene:
				DesignerState.finalize_placement(self)
	#if event is InputEventMouseButton and event.pressed:
		#print("Click received at:", get_global_mouse_position())
		# Add this outside of the mouse button check
	if event.is_action_pressed("space"):
		_center_on_first_player_preview()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		grid_controls.visible = false
		save_load.visible = false
		designer_settings.visible = false
	# Clear the currently dragged preview (if any)
		if is_instance_valid(DesignerState.dragging_scene):
			DesignerState.dragging_scene.queue_free()
		
		DesignerState.dragging_scene = null
		DesignerState.scene_being_dragged = null
		DesignerState.preview_scene = null

func _on_asset_selected(preview_path: String, runtime_path: String):
	var preview_scene = load(preview_path) as PackedScene
	var runtime_scene = load(runtime_path) as PackedScene

	if preview_scene and runtime_scene:
		DesignerState.preview_scene = preview_scene
		DesignerState.scene_being_dragged = runtime_scene
		DesignerState.dragging_scene = preview_scene.instantiate() as Node2D
		DesignerState.dragging_scene.modulate.a = 0.5  # semi-transparent preview

		var mouse_pos := get_viewport().get_camera_2d().get_global_mouse_position()
		DesignerState.dragging_scene.global_position = mouse_pos

		add_child(DesignerState.dragging_scene)

func _on_play_pressed() -> void:
	var play_scene = load("res://Scenes/Designer/play_mode.tscn") as PackedScene
	get_tree().change_scene_to_packed(play_scene)


func _on_save_pressed() -> void:
	DesignerState.save_to_file()


func _on_load_pressed() -> void:
	DesignerState.load_from_file()

func _on_button_pressed(button_name: String):
	match button_name:
		"grid_controls":
			grid_controls.visible = true
		"designer_settings":
			designer_settings.visible = true
		"save_load":
			save_load.visible = true

func reload_designer_objects():
	for obj in DesignerState.pending_objects:
		var preview_scene = load(obj["preview_path"]) as PackedScene
		if preview_scene:
			var instance = preview_scene.instantiate() as Node2D
			instance.global_position = obj["position"]
			instance.modulate.a = 0.5
			add_child(instance)

func _center_on_first_player_preview() -> void:
	var players = get_tree().get_nodes_in_group("player_preview")

	if players.size() > 0:
		var first_player = players[0] as Node2D
		designer_camera.global_position = first_player.global_position
