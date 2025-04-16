# DesignerState.gd
extends Node

var cell_size: Vector2 = Vector2(64, 64)
var grid_size: Vector2i = Vector2i(500, 500)

var preview_scene: PackedScene = null  # New!
var dragging_scene: Node2D = null
var scene_being_dragged: PackedScene = null
var pending_objects: Array = []
var grid_snap_enabled: bool = true

func clear():
	pending_objects.clear()

func cursor_is_empty() -> bool:
	return dragging_scene == null

func pick_up_preview(preview_path: String, runtime_path: String, node: Node2D):
	var scene_root: Node = null
	if node.get_tree() != null:
		scene_root = node.get_tree().current_scene
	else:
		print("⚠ Cannot access scene tree.")
		return

	var mouse_pos := node.global_position

	# ✅ Remove from pending_objects by matching preview_path + position
	pending_objects = pending_objects.filter(func(obj):
		return obj["preview_path"] != preview_path or obj["position"] != mouse_pos
	)

	# ✅ Remove and free the visual node
	if node.get_parent():
		node.get_parent().remove_child(node)
		node.queue_free()

	# ✅ Load the preview scene from the given path
	preview_scene = load(preview_path) as PackedScene
	if preview_scene == null:
		print("⚠ Failed to load preview scene from path:", preview_path)
		return

	# ✅ Load the runtime scene from the given path
	scene_being_dragged = load(runtime_path) as PackedScene
	if scene_being_dragged == null:
		print("⚠ Failed to load runtime scene from path:", runtime_path)
		return

	# ✅ Create the dragging preview
	dragging_scene = preview_scene.instantiate() as Node2D
	dragging_scene.modulate.a = 0.5
	dragging_scene.global_position = mouse_pos
	scene_root.add_child(dragging_scene)


func finalize_placement(parent: Node):
	if preview_scene == null or scene_being_dragged == null:
		print("⚠ Cannot place item — no preview or runtime scene loaded.")
		return

	var mouse_pos := parent.get_viewport().get_camera_2d().get_global_mouse_position()
	var final_pos = mouse_pos

	if grid_snap_enabled:
		var cell_size = cell_size
		final_pos = Vector2(
			floor(mouse_pos.x / cell_size.x) * cell_size.x + cell_size.x / 2,
			floor(mouse_pos.y / cell_size.y) * cell_size.y + cell_size.y / 2
		)

	var instance = preview_scene.instantiate() as Node2D
	instance.global_position = final_pos

	# ✅ Assign the preview_path to the instance so it can be picked up later
	if "preview_path" in instance:
		instance.preview_path = preview_scene.resource_path
	if "runtime_path" in instance:
		instance.runtime_path = scene_being_dragged.resource_path
	
	parent.add_child(instance)

	pending_objects.append({
		"preview_path": preview_scene.resource_path,
		"runtime_path": scene_being_dragged.resource_path,
		"position": final_pos
	})

	if is_instance_valid(dragging_scene):
		dragging_scene.queue_free()

	# Recreate the drag preview
	dragging_scene = preview_scene.instantiate() as Node2D
	dragging_scene.modulate.a = 0.5
	parent.add_child(dragging_scene)
	dragging_scene.global_position = parent.get_viewport().get_camera_2d().get_global_mouse_position()



func save_to_file(path: String = "user://designer_save.json") -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)

	var serialized_data := []
	for obj in pending_objects:
		serialized_data.append({
			"preview_path": obj["preview_path"],
			"runtime_path": obj["runtime_path"],
			"position": {
				"x": obj["position"].x,
				"y": obj["position"].y
			}
		})

	file.store_string(JSON.stringify(serialized_data))
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
			instance.global_position = Vector2(obj["position"]["x"], obj["position"]["y"])
			instance.modulate.a = 0.5
			get_tree().get_current_scene().add_child(instance)

			pending_objects.append({
				"preview_path": obj["preview_path"],
				"runtime_path": obj["runtime_path"],
				"position": instance.global_position
			})
