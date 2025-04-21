extends Control

@export var scene_path: String
@export var runtime_scene_path: String

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

signal asset_selected(preview_path: String, runtime_path: String)

func _ready():
	var name := scene_path.get_file().get_basename()
	label.text = name

	var scene: PackedScene = load(scene_path)
	if scene:
		var instance: Node = scene.instantiate()
		var sprite: Sprite2D = instance.find_child("Sprite2D", true, false)
		if sprite and sprite.texture:
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

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		emit_signal("asset_selected", scene_path, runtime_scene_path)
