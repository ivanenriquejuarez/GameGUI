@tool
extends Node2D

@onready var save_load = $DesignerCamera/CanvasLayer/SaveLoad
@onready var designer_settings = $DesignerCamera/CanvasLayer/DesignerSettings
@onready var grid_controls = $DesignerCamera/CanvasLayer/gridControls
@onready var grid_display: GridDisplay = $GridDisplay
@onready var asset_library := (
	$DesignerCamera/CanvasLayer/accordion_menu/HorizontalMenu/MenuHolder/CollapsibleContainer/MarginContainer/VBoxContainer/SubMenu3/CollapsibleContainer/MarginContainer/AssetLibrary
) as AssetLibrary

signal button_pressed(button_name: String)

func _ready():
	connect("button_pressed", Callable(self, "handle_button_press"))
	if asset_library.has_signal("asset_selected"):
		asset_library.connect("asset_selected", Callable(self, "_on_asset_selected"))
	grid_controls.visible = false
	save_load.visible = false
	designer_settings.visible = false
	apply_grid_settings()

func apply_grid_settings():
	if Engine.is_editor_hint():
		return
	
	if grid_display:
		grid_display.grid_size = DesignerState.grid_size
		grid_display.cell_size = DesignerState.cell_size


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return  # Don’t run this in the editor

	if is_instance_valid(DesignerState.dragging_scene):
		var mouse_pos := get_viewport().get_camera_2d().get_global_mouse_position()
		DesignerState.dragging_scene.global_position = mouse_pos
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if DesignerState.dragging_scene:
				DesignerState.finalize_placement(self)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		grid_controls.visible = false
		save_load.visible = false
		designer_settings.visible = false

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
