extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera2D = $Camera2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var _moved_this_frame: bool = false
var _is_dead: bool = false
@export_category("Camera Settings")
@export var left: int = -10000000
@export var right: int = 10000000
@export var top: int = -10000000
@export var bottom: int = 10000000
@export var camera_zoom_x: float = 3.0
@export var camera_zoom_y: float = 3.0
@export var camera_x_transform: float = 0
@export var camera_y_transform: float = 0 
@export var base_damage: int = 0

var reward_node = get_node
func _ready() -> void:
	camera.limit_bottom = bottom
	camera.limit_top = top
	camera.limit_left = left
	camera.limit_right = right
	camera.zoom.x = camera_zoom_x
	camera.zoom.y = camera_zoom_y
	camera.position.x = camera_x_transform
	camera.position.y = camera_y_transform
	
## When agent is damaged...
func _damaged(_amount: float, knockback: Vector2) -> void:
	apply_knockback(knockback)
	#animation_player.play(&"hurt")

#func receives_knockback(damage_source_pos: Vector2, received_damage: int):
	#pass
func apply_knockback(knockback: Vector2, frames: int = 10) -> void:
	if knockback.is_zero_approx():
		return
	for i in range(frames):
		move(knockback)
		await get_tree().physics_frame

func move(p_velocity: Vector2) -> void:
	velocity = lerp(velocity, p_velocity, 0.2)
	move_and_slide()
	_moved_this_frame = true

func get_facing() -> float:
	return 1
