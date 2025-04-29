extends Node

var cell_size: Vector2 = Vector2(64, 64)
var grid_size: Vector2i = Vector2i(500, 500)

var preview_scene: PackedScene = null
var dragging_scene: Node2D = null
var scene_being_dragged: PackedScene = null
var pending_objects: Array = []
var grid_snap_enabled: bool = true
var save_timestamp: String = ""

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

	var matched_obj = null
	for obj in pending_objects:
		if obj["preview_path"] == preview_path and obj["position"] == mouse_pos:
			matched_obj = obj
			break

	if matched_obj == null:
		print("⚠ No matching object found for pickup.")
		return

	pending_objects = pending_objects.filter(func(obj):
		return obj != matched_obj
	)

	if node.get_parent():
		node.get_parent().remove_child(node)
		node.queue_free()

	preview_scene = load(preview_path) as PackedScene
	if preview_scene == null:
		print("⚠ Failed to load preview scene:", preview_path)
		return

	scene_being_dragged = load(runtime_path) as PackedScene
	if scene_being_dragged == null:
		print("⚠ Failed to load runtime scene:", runtime_path)
		return

	dragging_scene = preview_scene.instantiate() as Node2D
	dragging_scene.modulate.a = 0.5
	dragging_scene.global_position = mouse_pos

	if "scale" in matched_obj:
		dragging_scene.scale = matched_obj["scale"]
	else:
		dragging_scene.scale = Vector2(1, 1)

	scene_root.add_child(dragging_scene)

func finalize_placement(parent: Node, scale_factor: float):
	if preview_scene == null or scene_being_dragged == null:
		print("⚠ Cannot place item — no preview or runtime scene loaded.")
		return

	var mouse_pos := parent.get_viewport().get_camera_2d().get_global_mouse_position()
	var final_pos = mouse_pos

	if grid_snap_enabled:
		var size = cell_size
		final_pos = Vector2(
			floor(mouse_pos.x / size.x) * size.x + size.x / 2,
			floor(mouse_pos.y / size.y) * size.y + size.y / 2
		)

	var instance = preview_scene.instantiate() as Node2D
	instance.global_position = final_pos
	instance.scale = Vector2(scale_factor, scale_factor)

	parent.add_child(instance)

	pending_objects.append({
		"preview_path": preview_scene.resource_path,
		"runtime_path": scene_being_dragged.resource_path,
		"position": final_pos,
		"scale": instance.scale
	})

	if is_instance_valid(dragging_scene):
		dragging_scene.queue_free()

	dragging_scene = preview_scene.instantiate() as Node2D
	dragging_scene.modulate.a = 0.5
	parent.add_child(dragging_scene)
	dragging_scene.global_position = parent.get_viewport().get_camera_2d().get_global_mouse_position()
	dragging_scene.scale = Vector2(scale_factor, scale_factor)

func save_to_file(path: String = "user://designer_save.json") -> void:
	var datetime = Time.get_datetime_dict_from_system()
	save_timestamp = "%04d-%02d-%02d %02d:%02d" % [
		datetime.year,
		datetime.month,
		datetime.day,
		datetime.hour,
		datetime.minute
	]

	var file = FileAccess.open(path, FileAccess.WRITE)
	var save_data = {
		"timestamp": save_timestamp,
		"objects": []
	}

	for obj in pending_objects:
		save_data["objects"].append({
			"preview_path": obj["preview_path"],
			"runtime_path": obj["runtime_path"],
			"position": {
				"x": obj["position"].x,
				"y": obj["position"].y
			},
			"scale": {
				"x": obj["scale"].x,
				"y": obj["scale"].y
			}
		})

	file.store_string(JSON.stringify(save_data))
	print("✅ Designer saved:", path)

func load_from_file(path: String = "user://designer_save.json") -> void:
	if not FileAccess.file_exists(path):
		print("❌ Designer save file not found:", path)
		return

	clear()

	var file = FileAccess.open(path, FileAccess.READ)
	var json_string = file.get_as_text()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		print("❌ JSON Parse Error:", json.get_error_message())
		return

	var data = json.get_data()

	if data is Dictionary and data.has("timestamp"):
		save_timestamp = data["timestamp"]
		if data.has("objects"):
			data = data["objects"]
	else:
		save_timestamp = "Unknown"

	var scene_root = get_tree().get_current_scene()
	if scene_root == null:
		print("❌ Cannot load save: current scene is null.")
		return

	if data is Array:
		for obj in data:
			var preview_scene = load(obj["preview_path"]) as PackedScene
			if preview_scene == null:
				print("⚠ Failed to load preview:", obj["preview_path"])
				continue

			var instance = preview_scene.instantiate() as Node2D
			instance.global_position = Vector2(obj["position"]["x"], obj["position"]["y"])

			if "scale" in obj:
				instance.scale = Vector2(obj["scale"]["x"], obj["scale"]["y"])
			else:
				instance.scale = Vector2(1, 1)

			scene_root.add_child(instance)

			pending_objects.append({
				"preview_path": obj["preview_path"],
				"runtime_path": obj["runtime_path"],
				"position": instance.global_position,
				"scale": instance.scale
			})
	else:
		print("❌ Invalid save data format.")
