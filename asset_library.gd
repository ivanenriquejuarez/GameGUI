class_name AssetLibrary
extends Control

@onready var grid: GridContainer = $ScrollContainer/GridContainer

signal asset_selected(preview_path: String, runtime_path: String)

@export var asset_list: Array = []

func _ready():
	# No more auto-populating here!
	pass

func populate_assets():
	if asset_list.is_empty():
		return

	var asset_button_scene = preload("res://UIElements/DesignerUI/asset_button.tscn")

	for asset in asset_list:
		var asset_button = asset_button_scene.instantiate()
		asset_button.scene_path = asset.preview
		asset_button.runtime_scene_path = asset.runtime
		asset_button.asset_selected.connect(_on_asset_button_selected)
		grid.add_child(asset_button)

func _on_asset_button_selected(preview_path: String, runtime_path: String):
	emit_signal("asset_selected", preview_path, runtime_path)
