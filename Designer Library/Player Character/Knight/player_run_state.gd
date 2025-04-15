extends NodeState

signal death

@export_category("Player run state")

@export var character_body_2d : CharacterBody2D
@export var speed : int = 200
@export var max_horizontal_speed : int = 200

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var sprite_2d: Sprite2D = $"../../Sprite2D"
@onready var run_sound: AudioStreamPlayer2D = $"../../RunSound"

var can_dash: bool = true
var _is_dead: bool = false
var _moved_this_frame: bool = false


func _ready() -> void:
	pass

func on_process(_delta :float):
	pass
	
func on_physics_process(_delta :float):
	var direction : float = GameInputEvents.movement_input()
	if direction > 0.0 and sprite_2d.scale.x < 0.0:
		sprite_2d.scale.x = 1.0;
	if direction < 0.0 and sprite_2d.scale.x > 0.0:
		sprite_2d.scale.x = -1.0;
	#This allows increasing speed with an upper and lower bound
	#ie: you can build momentum up to a cap, this could be fun(ny)
	if direction:
		character_body_2d.velocity.x += direction * speed
		character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -max_horizontal_speed, max_horizontal_speed)
	
	#if direction != 0:
		#sprite_2d.flip_h = false if direction > 0 else true
		#hitbox.scale.x = -1 if sprite_2d.flip_h else 1  # Update hitbox scale based on sprite flip
		
	character_body_2d.move_and_slide()
	
	# Smooth stop when landing
	if character_body_2d.is_on_floor() and direction == 0:
		character_body_2d.velocity.x = lerp(character_body_2d.velocity.x, 0.0, 0.3)  # Adjust the lerp factor as needed
		
	#Transition
	if direction == 0:
		transition.emit("Idle")
		
	if GameInputEvents.jump_input():
		transition.emit("Jump")
		
	if GameInputEvents.attack1_input():
		transition.emit("Attack1")
	
	if GameInputEvents.attack2_input():
		transition.emit("Attack2")
	
	if !character_body_2d.is_on_floor():
		transition.emit("Fall")
		
	if GameInputEvents.control_input() && character_body_2d.velocity.x < 1:
		transition.emit("Crouch")
		
	if GameInputEvents.control_input() && character_body_2d.velocity.x >= 1:
		transition.emit("CrouchWalk")
		
	#if GameInputEvents.shift_input() && direction != 0:
	if GameInputEvents.shift_input():
			transition.emit("Dash")

func _post_physics_process() -> void:
	if not _moved_this_frame:
		character_body_2d.velocity.x = lerp(character_body_2d.velocity.x, 0.0, 0.2)  # Adjust as needed
	_moved_this_frame = false
	
func move(p_velocity: Vector2) -> void:
	character_body_2d.velocity = lerp(character_body_2d.velocity, p_velocity, 0.2)
	character_body_2d.move_and_slide()
	_moved_this_frame = true
	
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


	
func die() -> void:
	if _is_dead:
		return
	death.emit()
	_is_dead = true
	pass
	
func enter():
	run_sound.play()
	animation_player.play("Run")
	
func exit():
	#pass
	run_sound.stop()
	animation_player.stop()
