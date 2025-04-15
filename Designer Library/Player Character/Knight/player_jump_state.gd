extends NodeState

signal death

@export_category("Jump state")

@export var character_body_2d : CharacterBody2D
@export var jump_power : int = 350
@export var gravity : int = 700
@export var air_horizontal_speed: int = 200  # Simplified for air movement
@export var max_air_horizontal_speed: int = 200

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var sprite_2d: Sprite2D = $"../../Sprite2D"

var _is_dead: bool = false
var _moved_this_frame: bool = false
#var _has_jumped: bool = false  # Flag to track if the jump has been initiated


func _ready() -> void:
	pass

func on_process(_delta: float):
	pass
	
func on_physics_process(_delta: float):
	var direction: float = GameInputEvents.movement_input()
	if direction > 0.0 and sprite_2d.scale.x < 0.0:
		sprite_2d.scale.x = 1.0;
	if direction < 0.0 and sprite_2d.scale.x > 0.0:
		sprite_2d.scale.x = -1.0;
	# Apply gravity to the vertical velocity
	character_body_2d.velocity.y += gravity * _delta
	
	# Allow air control regardless of direction input
	#if direction != 0:
		#sprite_2d.flip_h = false if direction > 0 else true 

	# Apply horizontal movement while in the air
	var target_velocity_x = direction * air_horizontal_speed
	character_body_2d.velocity.x = lerp(character_body_2d.velocity.x, target_velocity_x, 0.1)  # Smooth transition

	# Clamp horizontal velocity to max limit
	character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -max_air_horizontal_speed, max_air_horizontal_speed)

	if character_body_2d.is_on_floor():
		# Dampen horizontal velocity when on the floor
		character_body_2d.velocity.x = lerp(character_body_2d.velocity.x, 0.0, 0.3)

	# Move the character
	character_body_2d.move_and_slide()
	
	# Transition states
	# Transition to Fall if velocity.y > 0 (falling down) or Idle if grounded
	if character_body_2d.velocity.y > 100:
		transition.emit("Fall")
		
	elif character_body_2d.is_on_floor():
		transition.emit("Idle")
		
	if GameInputEvents.attack1_input() || GameInputEvents.attack2_input():
		transition.emit("JumpAttack")
	
	#if GameInputEvents.shift_input() && direction != 0:
	if GameInputEvents.shift_input():
		transition.emit("Dash")
	
	#if GameInputEvents.jump_input() and _has_jumped:
		#transition.emit("DoubleJump")
		
func _post_physics_process() -> void:
	if not _moved_this_frame:
		character_body_2d.velocity.x = lerp(character_body_2d.velocity.x, 0.0, 0.2)  # Adjust as needed
	_moved_this_frame = false
	
func _damaged(_amount: float, knockback: Vector2) -> void:
	# Handle damage and knockback
	apply_knockback(knockback)
	animation_player.play("Hurt")
	await animation_player.animation_finished

func apply_knockback(knockback: Vector2, frames: int = 10) -> void:
	if knockback.is_zero_approx():
		return
	for i in range(frames):
		move(knockback)
		await get_tree().physics_frame

func move(p_velocity: Vector2) -> void:
	character_body_2d.velocity = lerp(character_body_2d.velocity, p_velocity, 0.2)
	character_body_2d.move_and_slide()
	_moved_this_frame = true
	

func die() -> void:
	if _is_dead:
		return
	death.emit()
	_is_dead = true

func enter():
	character_body_2d.velocity.y = -jump_power  # Apply jump power to start jump
	animation_player.play("Jump")
	
func exit():
	pass
