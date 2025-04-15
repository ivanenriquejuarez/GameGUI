# DesignerState.gd
extends Node

var cell_size: Vector2 = Vector2(64, 64)
var grid_size: Vector2i = Vector2i(500, 500)

var preview_scene: PackedScene = null  # New!
var dragging_scene: Node2D = null
var scene_being_dragged: PackedScene = null
var pending_objects: Array = []

func clear():
	pending_objects.clear()

func cursor_is_empty() -> bool:
	return dragging_scene == null

func pick_up(node: Node2D):
	pending_objects = pending_objects.filter(func(obj): return obj["instance"] != node)
	dragging_scene = node
	scene_being_dragged = PackedScene.new()
	scene_being_dragged.pack(node)
	node.get_parent().remove_child(node)

func finalize_placement(parent: Node):
	var mouse_pos := parent.get_viewport().get_camera_2d().get_global_mouse_position()

	# ✅ Place the preview scene visually in the designer
	var instance = preview_scene.instantiate() as Node2D
	instance.global_position = mouse_pos
	parent.add_child(instance)

	# ✅ Store the runtime scene for play mode
	pending_objects.append({
	"preview_path": preview_scene.resource_path,
	"runtime_path": scene_being_dragged.resource_path,
	"position": instance.global_position
	})

	# ✅ Clean up preview
	if is_instance_valid(dragging_scene):
		dragging_scene.queue_free()

	dragging_scene = null
	scene_being_dragged = null
	preview_scene = null

func save_to_file(path: String = "user://designer_save.json") -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(pending_objects))
	print("Designer saved:", path)

func load_from_file(path: String = "user://designer_save.json") -> void:
	if not FileAccess.file_exists(path):
		print("Designer save file not found.")
		return

	clear()

	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())

	if data is Array:
		for obj in data:
			var preview_scene = load(obj["preview_path"]) as PackedScene
			var instance = preview_scene.instantiate() as Node2D
			instance.global_position = obj["position"]
			instance.modulate.a = 0.5  # semi-transparent like before
			get_tree().get_current_scene().add_child(instance)

			pending_objects.append({
				"preview_path": obj["preview_path"],
				"runtime_path": obj["runtime_path"],
				"position": obj["position"]
			})
