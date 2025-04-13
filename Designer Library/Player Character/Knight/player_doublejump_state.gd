extends NodeState

@export var character_body_2d : CharacterBody2D
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var sprite_2d: Sprite2D = $"../../Sprite2D"

@export_category("DoublJump state")
@export var jump : float = -350
@export var jump_speed : int = 10
@export var max_jump_speed : int = 200

@export var gravity : int = 800

func on_process(_delta :float):
	pass

func on_physics_process(_delta :float):
	
	character_body_2d.velocity.y += gravity * _delta
	
	if character_body_2d.is_on_floor():
		character_body_2d.velocity.y = jump
	
	var direction : float = GameInputEvents.movement_input()
	
	if direction != 0:
		sprite_2d.flip_h = false if direction > 0 else true 
	
	if !character_body_2d.is_on_floor():
		character_body_2d.velocity.x += direction * jump_speed
		character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -max_jump_speed,max_jump_speed)
		
	character_body_2d.move_and_slide()
	
	if character_body_2d.is_on_floor():
		transition.emit("Idle")
		
	if !character_body_2d.is_on_floor() and character_body_2d.velocity.y > 0:
		transition.emit("Fall")
		
	if GameInputEvents.shift_input():
		transition.emit("AirDash")
	
func enter():
	animation_player.play("Jump")
	
func exit():
	pass
	
