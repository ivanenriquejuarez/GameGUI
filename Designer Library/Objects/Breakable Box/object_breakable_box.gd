extends RigidBody2D

signal death

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health: Health = $Health
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var _is_dead: bool = false

func _ready() -> void:
	health.damaged.connect(_on_damaged)
	health.death.connect(die)

func _on_damaged(amount: float, knockback: Vector2) -> void:
	if _is_dead:
		return

	# Apply knockback
	apply_knockback(knockback)

	# Play the hurt animation
	animation_player.play("Hurt")

func apply_knockback(knockback: Vector2) -> void:
	# Add knockback to the rigid body's velocity
	linear_velocity += knockback
	#print("Knockback applied: ", knockback, ", New velocity: ", linear_velocity)

func die() -> void:
	if _is_dead:
		return

	_is_dead = true
	death.emit()
	
	 # Freeze the rigid body and reset its rotation
	#mode = RigidBody2D.MODE_STATIC
	rotation = 0  # Reset the box's rotation to upright
	collision_mask = 1 
	# Play the death animation
	animation_player.play("Death")

	# Wait for the death animation to finish, then disable collision and remove the object
	await animation_player.animation_finished
	collision_shape_2d.set_deferred("disabled", true)
	queue_free()
