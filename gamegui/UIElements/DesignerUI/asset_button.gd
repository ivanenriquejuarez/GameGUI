extends Control

@export var scene_path: String
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

signal asset_selected(scene_path: String)

func _ready():
	var name := scene_path.get_file().get_basename()
	label.text = name

	# Show first frame of sprite
	var scene: Resource = load(scene_path)
	if scene is PackedScene:
		var instance: Node = scene.instantiate()

		var sprite: Sprite2D = instance.find_child("Sprite2D", true, false)
		if sprite and sprite.texture:
			var tex: Texture2D = sprite.texture
			var hframes: int = sprite.hframes
			var vframes: int = sprite.vframes

			if hframes == 0: hframes = 1
			if vframes == 0: vframes = 1

			var frame_width: float = tex.get_width() / float(hframes)
			var frame_height: float = tex.get_height() / float(vframes)

			var region: Rect2 = Rect2(Vector2.ZERO, Vector2(frame_width, frame_height))

			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = region

			texture_rect.texture = atlas

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		emit_signal("asset_selected", scene_path)
