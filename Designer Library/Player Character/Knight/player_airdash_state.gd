extends NodeState

@export var character_body_2d : CharacterBody2D
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var sprite_2d: Sprite2D = $"../../Sprite2D"

@export_category("Player air dash state")
@export var speed : int = 400
@export var max_horizontal_speed : int = 400

func on_process(_delta :float):
	pass
	
func on_physics_process(_delta :float):
	var direction : float = GameInputEvents.movement_input()
	
	#This allows increasing speed with an upper and lower bound
	#ie: you can build momentum up to a cap, this could be fun(ny)
	if direction:
		character_body_2d.velocity.y = 0
		character_body_2d.velocity.x += direction * speed
		character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -max_horizontal_speed,max_horizontal_speed)
	
	if direction != 0:
		sprite_2d.flip_h = false if direction > 0 else true
		
	character_body_2d.move_and_slide()
	
	#Transition
	
func enter():
	animation_player.play("Dash")
	
func exit():
	animation_player.stop()


func _on_timer_timeout() -> void:
	transition.emit("Fall")
