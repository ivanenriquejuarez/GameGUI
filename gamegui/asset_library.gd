extends Control

@export var asset_paths: Array[String] # Fill this with your scene paths
@onready var grid: GridContainer = $ScrollContainer/GridContainer

signal asset_selected(scene_path: String)

func _ready():
	for path in asset_paths:
		var asset_button_scene = preload("res://UIElements/DesignerUI/asset_button.tscn")
		var asset_button = asset_button_scene.instantiate()
		asset_button.scene_path = path
		asset_button.asset_selected.connect(_on_asset_button_selected)
		grid.add_child(asset_button)

func _on_asset_button_selected(scene_path: String):
	emit_signal("asset_selected", scene_path)
