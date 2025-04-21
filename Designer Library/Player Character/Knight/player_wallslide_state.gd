extends NodeState

signal death

@export_category("Player WallSlide")

@export var character_body_2d : CharacterBody2D
@export var fall_speed : int = 300  # Speed of falling
@export var air_horizontal_speed: int = 200  # Horizontal speed in the air
@export var max_air_horizontal_speed: int = 200
#@export var speed : int = 200
#@export var max_horizontal_speed : int = 200

@onready var health: Health = $"../../Health"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var sprite_2d: Sprite2D = $"../../Sprite2D"
@onready var hitbox: Hitbox = $"../../Sprite2D/Hitbox"
@onready var stamina: Stamina = $"../../Stamina"
@onready var slide_hang: AudioStreamPlayer2D = $"../../SlideHang"

var can_dash: bool = true
var _is_dead: bool = false
var _moved_this_frame: bool = false

var wall_cling_direction : Vector2

func _ready() -> void:
	health.damaged.connect(_damaged)
	health.death.connect(die)

func on_process(_delta :float):
	pass
	
func on_physics_process(_delta :float):
	var direction : float = GameInputEvents.movement_input()
	if direction > 0.0 and sprite_2d.scale.x > 0.0:
		sprite_2d.scale.x = -1.0;
	if direction < 0.0 and sprite_2d.scale.x < 0.0:
		sprite_2d.scale.x = 1.0;
	
	character_body_2d.velocity.y = 0
	character_body_2d.velocity.y += fall_speed * _delta
	#This allows increasing speed with an upper and lower bound
	#ie: you can build momentum up to a cap, this could be fun(ny)
	
	if direction != 0 and wall_cling_direction == Vector2.ZERO:
		wall_cling_direction = Vector2.RIGHT if direction > 0 else Vector2.LEFT
		
	
	character_body_2d.move_and_slide()
	
	
		
	#Transition
	if direction == 0:
		transition.emit("Idle")
		
	if GameInputEvents.jump_input():
		if stamina.use_stamina(1):
			transition.emit("Jump")
		
	if GameInputEvents.attack1_input() || GameInputEvents.attack2_input():
		if stamina.use_stamina(1):
			transition.emit("WallAttack")
	
	if !character_body_2d.is_on_floor() and !character_body_2d.is_on_wall() and character_body_2d.velocity.y > 300:
		transition.emit("Fall")
		
	#if GameInputEvents.control_input() && character_body_2d.velocity.x < 1:
		#transition.emit("Crouch")
		
	#if GameInputEvents.control_input() && character_body_2d.velocity.x >= 1:
		#transition.emit("Slide")
		
	if GameInputEvents.shift_input():
		if stamina.use_stamina(2):
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

func get_health() -> Health:
	return health

	
func die() -> void:
	if _is_dead:
		return
	death.emit()
	_is_dead = true
	pass
	
func enter():
	slide_hang.play()
	animation_player.play("WallSlide")
	
func exit():
	slide_hang.stop()
	wall_cling_direction = Vector2.ZERO
	animation_player.stop()


func _on_dash_timer_timeout() -> void:
	can_dash = true
	print(can_dash)
