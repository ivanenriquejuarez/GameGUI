extends NodeState

signal death

@export_category("Friction")
@export_category("Idle state")

@export var character_body_2d : CharacterBody2D
@export var gravity : int = 700
@export var friction : int = 700

@onready var health: Health = $"../../Health"
@onready var hitbox: Hitbox = $"../../Sprite2D/Hitbox"
@onready var hurtbox: Hurtbox = $"../../Sprite2D/Hurtbox"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var stamina: Stamina = $"../../Stamina"
@onready var sprite_2d: Sprite2D = $"../../Sprite2D"

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
		
	character_body_2d.velocity.x = move_toward(character_body_2d.velocity.x, 0, friction * _delta)
	character_body_2d.move_and_slide()
	
	# Apply gravity if character is in the air
	if !character_body_2d.is_on_floor():
		character_body_2d.velocity.y += gravity * _delta
	else:
		character_body_2d.velocity.y = 0
		
	#Transitions
	if !character_body_2d.is_on_floor():
		transition.emit("Fall")
	
	#if direction and character_body_2d.is_on_floor():
	if abs(direction) > MOVEMENT_THRESHOLD and character_body_2d.is_on_floor():
		transition.emit("Run")
	elif !character_body_2d.is_on_floor():
		transition.emit("Fall")
	else:
		transition.emit("Idle")
		
	if GameInputEvents.jump_input():
		if stamina.use_stamina(1):
			transition.emit("Jump")
		
	if GameInputEvents.attack1_input():
		if stamina.use_stamina(1):
			transition.emit("Attack1")
	
	if GameInputEvents.attack2_input():
		if stamina.use_stamina(1):
			transition.emit("Attack2")
		
	if GameInputEvents.control_input():
		transition.emit("Crouch")
		
	#if GameInputEvents.shift_input() && direction !=0:
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
	#transition.emit("Hurt")
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
	#animation_player.play("Idle", blend_time=0.1)
	animation_player.play("Idle")
	
func exit():
	pass
	#await get_tree().create_timer(0.01).timeout
	#animation_player.stop()
