extends NodeState

signal death

@export_category("Dash State")

@export var character_body_2d: CharacterBody2D
@export var dash_distance: float = 350.0
@export var dash_duration: float = 0.27  # Duration of the dash in seconds
@export var ghost_node : PackedScene
@export var player: CharacterBody2D

@onready var sprite_2d: Sprite2D = $"../../Sprite2D"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var health: Health = $"../../Health"
@onready var ghost_timer: Timer = $"../../Sprite2D/GhostTimer"
@onready var stamina: Stamina = $"../../Stamina"
@onready var dash: AudioStreamPlayer2D = $"../../Dash"

var _is_dead: bool = false
var _is_dashing: bool = false  # Flag to track if dashing

func _ready() -> void:
	health.damaged.connect(_damaged)
	health.death.connect(die)

func on_process(_delta: float):
	pass
	
func on_physics_process(_delta: float):
	var direction : float = GameInputEvents.movement_input()
	if direction > 0.0 and sprite_2d.scale.x < 0.0:
		sprite_2d.scale.x = 1.0;
	if direction < 0.0 and sprite_2d.scale.x > 0.0:
		sprite_2d.scale.x = -1.0;
		
	if _is_dashing:
		character_body_2d.velocity = Vector2(dash_distance * direction, 0)
		character_body_2d.move_and_slide()
		return  # Skip further processing while dashing

	# Check for other inputs
	if character_body_2d.is_on_floor():
		transition.emit("Idle")
	else:
		transition.emit("Fall")


	if GameInputEvents.jump_input() && character_body_2d.is_on_floor():
		if stamina.use_stamina(1):
			transition.emit("Jump")
	elif GameInputEvents.jump_input() && !character_body_2d.is_on_floor():
		if stamina.use_stamina(3):
			transition.emit("Jump")
	#elif abs(direction) > 0.1:
		#transition.emit("Run")

func enter():
	player.collision_layer = 0
	#self.collision_mask = 1
	player.collision_mask &= ~(1 << 2)  # Remove layer 3 (bit 2)
# Reset the dash timer when entering the dash state
	ghost_timer.start()
	_is_dashing = true
	dash.play()
	animation_player.play("Dash")

		# Use a timer to exit the dash state after the duration
	await get_tree().create_timer(dash_duration).timeout  # Use yield to wait for the timer
	_is_dashing = false
	ghost_timer.stop()
	transition.emit("Idle")

func exit():
	dash.stop()
	player.collision_layer = 2
	#self.collision_mask = 1
	player.collision_mask |= 1 << 2  # Add layer 3 (bit 2)
	#print("Dashing ended!")  # Debug statement
	_is_dashing = false
	#character_body_2d.velocity.x = 0  # Stop the dash velocity
	animation_player.stop()

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

func move(p_velocity: Vector2) -> void:
	character_body_2d.velocity = lerp(character_body_2d.velocity, p_velocity, 0.2)
	character_body_2d.move_and_slide()

func get_health() -> Health:
	return health

func die() -> void:
	if _is_dead:
		return
	death.emit()
	_is_dead = true



func add_ghost():
	var ghost = ghost_node.instantiate()
	# Adjust the ghost's position to be 40 pixels higher
	ghost.position = character_body_2d.global_position + Vector2(0, -40)  # Adjust Y position
	# Flip ghost based on the direction of the character
	if character_body_2d.velocity.x < 0:  # Dashing left
		ghost.scale.x = -abs(character_body_2d.scale.x)  # Flip the ghost horizontally
	else:  # Dashing right or not moving
		ghost.scale.x = abs(character_body_2d.scale.x)  # Ensure the ghost is facing right
	get_tree().current_scene.add_child(ghost)
	


func _on_ghost_timer_timeout() -> void:
	add_ghost()
