extends NodeState

signal death

@export_category("Attack1 state")

@export var character_body_2d : CharacterBody2D
@export var friction : int = 500

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var sprite_2d: Sprite2D = $"../../Sprite2D"
@onready var health: Health = $"../../Health"

var _is_dead: bool = false
var _moved_this_frame: bool = false

func _ready() -> void:
	health.damaged.connect(_damaged)
	health.death.connect(die)
	
func on_process(_delta :float):
	pass

func on_physics_process(_delta :float):
	character_body_2d.velocity.x = move_toward(character_body_2d.velocity.x,0,friction)
	character_body_2d.move_and_slide()

func _post_physics_process() -> void:
	if not _moved_this_frame:
		character_body_2d.velocity.x = lerp(character_body_2d.velocity.x, 0.0, 0.2)  # Adjust as needed
	_moved_this_frame = false
	
func enter():
	var direction : float = GameInputEvents.movement_input()
	if direction > 0.0 and sprite_2d.scale.x < 0.0:
		sprite_2d.scale.x = 1.0;
	if direction < 0.0 and sprite_2d.scale.x > 0.0:
		sprite_2d.scale.x = -1.0;
	animation_player.play("Attack1")
	await animation_player.animation_finished
	transition.emit("Idle")

func _damaged(_amount: float, knockback: Vector2) -> void:
	#print("Current Health: ", health.get_current())  # Print the current health
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
	
func move(p_velocity: Vector2) -> void:
	character_body_2d.velocity = lerp(character_body_2d.velocity, p_velocity, 0.2)
	character_body_2d.move_and_slide()
	_moved_this_frame = true

func exit():
	pass
