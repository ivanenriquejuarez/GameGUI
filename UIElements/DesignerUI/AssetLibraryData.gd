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
