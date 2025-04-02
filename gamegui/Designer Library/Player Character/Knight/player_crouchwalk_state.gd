extends NodeState

signal death

@export_category("Player Crouch Walk state")

@export var speed : int = 150
@export var max_horizontal_speed : int = 150
@export var character_body_2d : CharacterBody2D

@onready var health: Health = $"../../Health"
@onready var stamina: Stamina = $"../../Stamina"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var sprite_2d: Sprite2D = $"../../Sprite2D"
@onready var run_sound: AudioStreamPlayer2D = $"../../RunSound"

var _is_dead: bool = false
var _moved_this_frame: bool = false
const MOVEMENT_THRESHOLD: float = 0.1

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
	
	#This allows increasing speed with an upper and lower bound
	#ie: you can build momentum up to a cap, this could be fun(ny)
	if direction:
		character_body_2d.velocity.x += direction * speed
		character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -max_horizontal_speed,max_horizontal_speed)
		
	character_body_2d.move_and_slide()
		
		
	#Transitions
	if character_body_2d.is_on_floor() && !GameInputEvents.control_input():
		transition.emit("Idle")
	
	if character_body_2d.is_on_floor() && GameInputEvents.control_input() && direction == 0:
		transition.emit("Crouch")
		
	if !character_body_2d.is_on_floor():
		transition.emit("Fall")
	
	#if GameInputEvents.shift_input() && direction !=0:
	if GameInputEvents.shift_input():
		if stamina.use_stamina(2):
			transition.emit("Dash")
			
	if GameInputEvents.attack1_input() || GameInputEvents.attack2_input():
		if stamina.use_stamina(1):
			transition.emit("CrouchAttack")
			
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

func get_health() -> Health:
	return health

	
func die() -> void:
	if _is_dead:
		return
	death.emit()
	_is_dead = true
	pass
	
func enter():
	run_sound.volume_db = -10  # Lower the volume for running
	run_sound.play()
	animation_player.play("Crouch_Walk")
	
func exit():
	run_sound.volume_db = 0
	run_sound.stop()
