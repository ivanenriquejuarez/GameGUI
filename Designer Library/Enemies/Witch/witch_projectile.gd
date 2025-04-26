extends RigidBody2D

const SPEED := 275.0  # Horizontal speed
const GRAVITY := 95.0  # Gravity for gradual vertical drop

@export var dir: float = 1.0  # Direction (1 for right, -1 for left)

var _is_dead: bool = false
var velocity: Vector2

@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var projectile: Sprite2D = $Root/projectile

func _ready() -> void:
	# Flip sprite when shooting left
	projectile.flip_h = dir < 0  

	# Set the initial velocity
	velocity = Vector2(SPEED * dir, 0)  # Start with horizontal velocity
	timer.start()  # Start the lifetime timer

func _physics_process(delta: float) -> void:
	if not _is_dead:
		# Apply gravity to vertical velocity over time
		velocity.y += GRAVITY * delta

		# Move the projectile based on its velocity
		position += velocity * delta

func _die() -> void:
	if _is_dead:
		return
	_is_dead = true
	animation_player.play("Death")
	self.collision_layer = 0
	self.collision_mask = 1
	await animation_player.animation_finished
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	_die()

func _on_area_2d_body_entered(body: Node2D) -> void:
	_die()


func _on_hitbox_body_entered(body: Node2D) -> void:
	_die()
