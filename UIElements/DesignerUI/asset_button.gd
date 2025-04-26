extends Control

@export var scene_path: String
@export var runtime_scene_path: String

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

signal asset_selected(preview_path: String, runtime_path: String)

func _ready():
	var name := scene_path.get_file().get_basename()
	name = name.replace("_preview", "")
	label.text = name

	var scene: PackedScene = load(scene_path)
	if scene:
		var instance: Node = scene.instantiate()

		# First: Try to find Sprite2D
		var sprite: Sprite2D = instance.find_child("Sprite2D", true, false)
		if sprite and sprite.texture:
			_set_texture_from_sprite(sprite)
			return

		# Second: Try to find TileMapLayer
		var tilemap_layer: TileMapLayer = instance.find_child("TileMapLayer", true, false)
		if tilemap_layer:
			_add_tilemaplayer_as_child(tilemap_layer)
			return

		# Fallback
		texture_rect.texture = null

func _set_texture_from_sprite(sprite: Sprite2D):
	var tex: Texture2D = sprite.texture
	var hframes: int = sprite.hframes
	var vframes: int = sprite.vframes
	if hframes == 0: hframes = 1
	if vframes == 0: vframes = 1
	var region = Rect2(Vector2.ZERO, Vector2(tex.get_width() / hframes, tex.get_height() / vframes))
	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = region
	texture_rect.texture = atlas

func _add_tilemaplayer_as_child(original_tilemap_layer: TileMapLayer):
	var clone = original_tilemap_layer.duplicate()
	texture_rect.hide()  # Hide the TextureRect since we won't use it
	add_child(clone)
	clone.position = Vector2(32, 32)
	clone.scale = Vector2(2, 2)  # Adjust scale if needed so it fits inside the button


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		emit_signal("asset_selected", scene_path, runtime_scene_path)
