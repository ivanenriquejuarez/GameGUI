extends NodeState

@export var character_body_2d : CharacterBody2D
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var sprite_2d: Sprite2D = $"../../Sprite2D"

@export_category("Slide state")
@export var speed : int = 300
@export var max_horizontal_speed : int = 300
#@export var friction : int = 10

func on_process(_delta :float):
	pass
	
func on_physics_process(_delta :float):
	var direction : float = GameInputEvents.movement_input()
	
	character_body_2d.velocity.x += direction * speed
	character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -max_horizontal_speed,max_horizontal_speed)
	#character_body_2d.velocity.x = move_toward(character_body_2d.velocity.x,0,friction)
	if direction != 0:
		sprite_2d.flip_h = false if direction > 0 else true 
		
	character_body_2d.move_and_slide()
	print("Slide")
	#Transitions
	if character_body_2d.is_on_floor() && !GameInputEvents.control_input():
		transition.emit("Idle")
		
	if !character_body_2d.is_on_floor() and character_body_2d.velocity.y > 0:
		transition.emit("Fall")
	
func enter():
	animation_player.play("Slide")
	
func exit():
	pass
