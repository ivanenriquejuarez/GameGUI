extends CharacterBody2D

@export var character_body_2d : CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D
@export var gravity := 450.0  # Gravity force
@export var friction := 400.0  # Friction force to stop sliding

const SPEED = 200.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.y += gravity * delta
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite_2d.play("jump")
	# Handle movement input 
	if Input.is_action_pressed("move_left"):
		velocity.x = -SPEED
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.play("run")
	elif Input.is_action_pressed("move_right"):
		velocity.x = SPEED
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("run")
	else:
		# If not moving, play the idle animation
		velocity.x = lerp(velocity.x, 0.0, min(friction * delta, 1.0))
		if abs(velocity.x) < 10:  # Adjust this threshold if needed
			velocity.x = 0
			animated_sprite_2d.play("idle")
	# Move the character based on velocity
	move_and_slide()
