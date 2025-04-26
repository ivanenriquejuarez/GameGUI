extends Node  # Just a regular Node

class_name AssetLibraryData  # So you can preload easily

static var character_assets = [
	{
		"preview": "res://Designer Library/Player Character/Knight/knight_preview.tscn",
		"runtime": "res://Designer Library/Player Character/Knight/playerState.tscn"
	},
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
	# Add more characters...
]

static var tile_assets = [
	{
		"preview": "res://Designer Library/Blocks/box/box_preview.tscn",
		"runtime": "res://Designer Library/Blocks/box/box_block.tscn"
	},
	{
		"preview": "res://Designer Library/Blocks/brick/brick_preview.tscn",
		"runtime": "res://Designer Library/Blocks/brick/brick_block.tscn"
	},
	{
		"preview": "res://Designer Library/Blocks/dirt/dirt_preview.tscn",
		"runtime": "res://Designer Library/Blocks/dirt/dirt_block.tscn"
	},
	{
		"preview": "res://Designer Library/Blocks/exclamation/exclamation_preview.tscn",
		"runtime": "res://Designer Library/Blocks/exclamation/exclamation_block.tscn"
	},
	{
		"preview": "res://Designer Library/Blocks/grass/grass_preview.tscn",
		"runtime": "res://Designer Library/Blocks/grass/grass_block.tscn"
	},
	{
		"preview": "res://Designer Library/Blocks/gravel/gravel_preview.tscn",
		"runtime": "res://Designer Library/Blocks/gravel/gravel_block.tscn"
	},
	{
		"preview": "res://Designer Library/Blocks/ice/ice_preview.tscn",
		"runtime": "res://Designer Library/Blocks/ice/ice_block.tscn"
	},
	{
		"preview": "res://Designer Library/Blocks/question/question_preview.tscn",
		"runtime": "res://Designer Library/Blocks/question/question_block.tscn"
	},
	{
		"preview": "res://Designer Library/Blocks/snow/snow_preview.tscn",
		"runtime": "res://Designer Library/Blocks/snow/snow_block.tscn"
	},
	{
		"preview": "res://Designer Library/Blocks/stone/stone_preview.tscn",
		"runtime": "res://Designer Library/Blocks/stone/stone_block.tscn"
	},
	# Add more tiles...
]

static var object_assets = [
	{
		"preview": "res://Designer Library/Blocks/stone/stone_preview.tscn",
		"runtime": "res://Designer Library/Blocks/stone/stone_block.tscn"
	},
	# Add more objects...
]
