extends VBoxContainer

const ITEM_SCENE = preload("res://UIElements/MainLoad/load_file.tscn")

func _ready():
	spawn_items(5)  # Example: Create 5 items dynamically

func spawn_items(count: int):
	for i in range(count):
		var item = ITEM_SCENE.instantiate()
		add_child(item)
