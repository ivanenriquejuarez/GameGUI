extends CharacterBody2D

signal death
signal damaged_by_player

var _frames_since_facing_update: int = 0
var _is_dead: bool = false
var _moved_this_frame: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health: Health = $Health
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hurtbox: Hurtbox = $Sprite2D/Hurtbox
@onready var hitbox: Hitbox = $Sprite2D/Hitbox


#const jump_power = -300
const gravity = 50
const speed = 100


func _ready() -> void:
	health.damaged.connect(_damaged)
	health.death.connect(die)
	damaged_by_player.connect(_enter_invincibility_state)
	self.collision_layer = 3
	self.collision_layer = 1 | 2

func _physics_process(_delta: float) -> void:
	#if is_on_wall() and &"InRange":
		#velocity.y = jump_power
		#velocity.x = get_facing() * 10
	#else:
	velocity.y += gravity
	move_and_slide()
	_post_physics_process.call_deferred()

func _post_physics_process() -> void:
	if not _moved_this_frame:
		velocity = lerp(velocity, Vector2.ZERO, 0.5)
	_moved_this_frame = false
	
func move(p_velocity: Vector2) -> void:
	velocity = lerp(velocity, p_velocity, 0.2)
	move_and_slide()
	_moved_this_frame = true

@warning_ignore("shadowed_variable")
func walk(dir: float, speed: float) -> void:
	velocity.x = dir * speed

## Update agent's facing in the velocity direction.
func update_facing() -> void:
	_frames_since_facing_update += 1
	if _frames_since_facing_update > 3:
		face_dir(velocity.x)

## Face specified direction.
func face_dir(dir: float) -> void:
	if dir > 0.0 and sprite_2d.scale.x < 0.0:
		sprite_2d.scale.x = 1.0
		_frames_since_facing_update = 0
	if dir < 0.0 and sprite_2d.scale.x > 0.0:
		sprite_2d.scale.x = -1.0
		_frames_since_facing_update = 0

## Returns 1.0 when agent is facing right.
## Returns -1.0 when agent is facing left.
func get_facing() -> float:
	return sign(sprite_2d.scale.x)

## Is specified position inside the arena (not inside an obstacle)?
func is_good_position(p_position: Vector2) -> bool:
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = p_position
	params.collision_mask = 1 # Obstacle layer has value 1
	var collision = space_state.intersect_point(params)
	return collision.is_empty()

## When agent is damaged...
func _damaged(_amount: float, knockback: Vector2) -> void:
	if _is_dead:
		return
	emit_signal("damaged_by_player")
	apply_knockback(knockback)

		# Optional: show UI indicator
func _on_stunned() -> void:
	animation_player.play("Hurt")
	var btplayer = get_node_or_null("BTPlayer") as BTPlayer
	var hsm = get_node_or_null("LimboHSM")
	if btplayer:
		btplayer.set_active(false)
	if hsm:
		hsm.set_active(false)
	
	await get_tree().create_timer(1.5).timeout
	
	if btplayer and not _is_dead:
		btplayer.restart()
	if hsm and not _is_dead:
		hsm.set_active(true)

## Push agent in the knockback direction for the specified number of physics frames.
func apply_knockback(knockback: Vector2, frames: int = 10) -> void:
	if knockback.is_zero_approx():
		return
	for i in range(frames):
		move(knockback)
		await get_tree().physics_frame


func die() -> void:
	if _is_dead:
		return
	death.emit()
	_is_dead = true
	sprite_2d.process_mode = Node.PROCESS_MODE_DISABLED
	animation_player.play("Death")
	self.collision_layer = 0
	self.collision_mask = 1

	# Disable relevant children and prepare for destruction
	for child in get_children():
		if child is BTPlayer or child is LimboHSM:
			child.set_active(false)

	# Schedule spawning a new enemy after death animation

	# Remove the current instance after 10 seconds
	if get_tree():
		await get_tree().create_timer(5.0).timeout
		queue_free()
		
func show_hurt_ui():
	pass
	
func get_health() -> Health:
	return health
	
func _enter_invincibility_state() -> void:
	if _is_dead:
		return
	#var start_time := Time.get_ticks_msec()
	#print("Invincibility started at:", start_time, "ms")
	
	_set_hurtbox_enabled(false)

	var original_color: Color = Color(1, 1, 1, 1)
	var blink_timer := 0.0
	var blink_duration := .4
	var blink_interval := 0.2
	var white := Color(0, 0, 0, 0)

	while blink_timer < blink_duration:
		sprite_2d.modulate = white
		await get_tree().create_timer(blink_interval / 2).timeout
		sprite_2d.modulate = original_color
		await get_tree().create_timer(blink_interval / 2).timeout
		blink_timer += blink_interval

	sprite_2d.modulate = original_color
	
	_set_hurtbox_enabled(true)
	#var end_time := Time.get_ticks_msec()
	#print("Invincibility ended at:", end_time, "ms")
	#print("Total invincibility duration:", (end_time - start_time) / 1000.0, "seconds")
	
func _set_hurtbox_enabled(enabled: bool) -> void:
	for shape in hurtbox.get_children():
		shape.set_deferred("disabled", not enabled)
