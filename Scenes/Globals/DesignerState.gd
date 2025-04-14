# DesignerState.gd
extends Node

var cell_size: Vector2 = Vector2(64, 64)
var grid_size: Vector2i = Vector2i(500, 500)

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

	var instance = scene_being_dragged.instantiate() as Node2D
	instance.global_position = mouse_pos
	parent.add_child(instance)

	pending_objects.append({
		"scene": scene_being_dragged,
		"instance": instance,
		"position": instance.global_position
	})

	if is_instance_valid(dragging_scene):
		dragging_scene.queue_free()

	dragging_scene = null
	scene_being_dragged = null
