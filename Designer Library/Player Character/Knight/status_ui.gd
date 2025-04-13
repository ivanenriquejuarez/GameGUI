extends CanvasLayer

@export var full_heart_texture: Texture2D
@export var half_heart_texture: Texture2D
@export var empty_heart_texture: Texture2D
@onready var max_health: int = $"../../Health".max_health

var health_tiles: Array[TextureRect] = []
var hbox: HBoxContainer

@onready var health: Health = $"../../Health"

func _ready() -> void:
	var vbox = $VBoxContainer  # Adjust the path to your container
	vbox.anchor_left = 0.0
	vbox.anchor_right = 1.0
	vbox.anchor_top = 0.0
	vbox.anchor_bottom = 1.0

	# Health and stamina will now align vertically
	_create_health_tiles(vbox.get_node("HealthBar"), health_tiles, full_heart_texture, half_heart_texture, empty_heart_texture)


	# Connect signals from Health and Stamina nodes to the update functions
	health.connect("damaged", Callable(self, "_on_health_changed"))

# Create health tiles (full, half, empty hearts)
func _create_health_tiles(container: Node, tile_array: Array[TextureRect], full_heart: Texture2D, half_heart: Texture2D, empty_heart: Texture2D) -> void:
	for i in range(max_health / 2):  # 5 full hearts for max 10 health
		var tile = TextureRect.new()
		tile.texture = full_heart  # Default to full heart
		tile.modulate = Color(1, 1, 1, 1)  # Make sure it's visible
		container.add_child(tile)
		tile_array.append(tile)

# Update health (using full, half, and empty hearts)
func update_health(current_health: int) -> void:
	var full_hearts = current_health / 2
	var half_hearts = (current_health % 2) / 1
	var empty_hearts = (max_health / 2) - full_hearts - half_hearts

	for i in range(health_tiles.size()):
		if i < full_hearts:
			health_tiles[i].texture = full_heart_texture
		elif i < full_hearts + half_hearts:
			health_tiles[i].texture = half_heart_texture
		else:
			health_tiles[i].texture = empty_heart_texture
		health_tiles[i].modulate = Color(1, 1, 1, 1)

# Signal handlers for health and stamina changes
func _on_health_changed(amount: float, knockback: Vector2) -> void:
	update_health(health.get_current())

func set_max_health(new_max: int):
	max_health = new_max
	# Clear old hearts
	for tile in health_tiles:
		tile.queue_free()
	health_tiles.clear()
	
	_create_health_tiles($VBoxContainer/HealthBar, health_tiles, full_heart_texture, half_heart_texture, empty_heart_texture)
