class_name AssetLibrary
extends Control

@onready var grid: GridContainer = $ScrollContainer/GridContainer

signal asset_selected(preview_path: String, runtime_path: String)

# You define your asset list directly here
var asset_list := [
	
	{
		"preview": "res://Designer Library/Enemies/Eyeball/eyeball_preview.tscn",
		"runtime": "res://Designer Library/Enemies/Eyeball/enemy_eyeball.tscn"
	},
	{
		"preview": "res://Designer Library/Enemies/Werewolf_black/werewolf_preview.tscn",
		"runtime": "res://Designer Library/Enemies/Werewolf_black/enemy_werewolf_redd.tscn"
	},
	{
		"preview": "res://Designer Library/Enemies/Witch/witch_preview.tscn",
		"runtime": "res://Designer Library/Enemies/Witch/enemy_witch.tscn"
	},
	{
		"preview": "res://Designer Library/Enemies/Worm_red/worm_preview.tscn",
		"runtime": "res://Designer Library/Enemies/Worm_red/enemy_worm_fire.tscn"
	},
	{
		"preview": "res://Designer Library/Blocks/stone/stone_preview.tscn",
		"runtime": "res://Designer Library/Blocks/stone/stone_block.tscn"
	},
	{
		"preview": "res://Designer Library/Player Character/Knight/knight_preview.tscn",
		"runtime": "res://Designer Library/Player Character/Knight/playerState.tscn"
	},
]	

func _ready():
	var asset_button_scene = preload("res://UIElements/DesignerUI/asset_button.tscn")

	for asset in asset_list:
		var asset_button = asset_button_scene.instantiate()
		asset_button.scene_path = asset.preview
		asset_button.runtime_scene_path = asset.runtime
		asset_button.asset_selected.connect(_on_asset_button_selected)
		grid.add_child(asset_button)

func _on_asset_button_selected(preview_path: String, runtime_path: String):
	emit_signal("asset_selected", preview_path, runtime_path)
