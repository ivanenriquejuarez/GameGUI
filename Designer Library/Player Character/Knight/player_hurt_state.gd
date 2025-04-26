extends NodeState

signal death

@export_category("Hurt")

@export var character_body_2d : CharacterBody2D

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var health: Health = $"../../Health"
@onready var hurtbox: Hurtbox = $"../../Sprite2D/Hurtbox"
@onready var sprite_2d: Sprite2D = $"../../Sprite2D"

var animation_finished = false
var input_detected = false
var _is_dead: bool = false
var _moved_this_frame: bool = false

func _ready() -> void:
	health.damaged.connect(_damaged)
	health.death.connect(die)

func on_process(_delta :float):
	pass

func on_physics_process(_delta :float):
	var direction : float = GameInputEvents.movement_input()
	if direction > 0.0 and sprite_2d.scale.x < 0.0:
		sprite_2d.scale.x = 1.0;
	if direction < 0.0 and sprite_2d.scale.x > 0.0:
		sprite_2d.scale.x = -1.0;
		
	if animation_finished:
		transition.emit("Idle")
	elif GameInputEvents.shift_input():
		transition.emit("Dash")
	elif GameInputEvents.jump_input():
		transition.emit("Jump")
func _post_physics_process() -> void:
	if not _moved_this_frame:
		character_body_2d.velocity = lerp(character_body_2d.velocity, Vector2.ZERO, 0.5)
	_moved_this_frame = false
	
func move(p_velocity: Vector2) -> void:
	character_body_2d.velocity = lerp(character_body_2d.velocity, p_velocity, 0.2)
	character_body_2d.move_and_slide()
	_moved_this_frame = true

func _damaged(_amount: float, knockback: Vector2) -> void:
	apply_knockback(knockback)
	animation_player.play("Hurt")
	await animation_player.animation_finished


func apply_knockback(knockback: Vector2, frames: int = 10) -> void:
	if knockback.is_zero_approx():
		return
	for i in range(frames):
		move(knockback)
		await get_tree().physics_frame

func get_health() -> Health:
	return health
	
func die() -> void:
	if _is_dead:
		return
	death.emit()
	_is_dead = true
	pass
	
func _on_animation_finished(animation_name: String) -> void:
	animation_finished = true


func enter():
	animation_finished = false
	input_detected = false
	animation_player.play("Hurt")
	if animation_player.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
		animation_player.disconnect("animation_finished", Callable(self, "_on_animation_finished"))
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	

func exit():
	pass
	#await get_tree().create_timer(0.01).timeout
	#animation_player.stop()
