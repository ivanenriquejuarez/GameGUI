
extends CharacterBody2D
## Base agent script that is shared by all agents.

signal death

# Resource file to use in summon_minion() method.

# Projectile resource.
const Projectile := preload("res://Designer Library/Enemies/Eyeball/eyeball_projectile.tscn")

var summon_count: int = 0

var _frames_since_facing_update: int = 0
var _is_dead: bool = false
var _moved_this_frame: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health: Health = $Health
@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox: Hurtbox = $Sprite2D/Hurtbox
@onready var hitbox: Hitbox = $Sprite2D/Hitbox
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var flipped_collision_shape_2d: CollisionShape2D = $FlippedCollisionShape2D
const jump_power = -400

func _ready() -> void:
	health.damaged.connect(_damaged)
	health.death.connect(die)
	self.collision_layer = 3
	self.collision_layer = 1 | 2


func _physics_process(_delta: float) -> void:
	if _is_dead:
		velocity.y += 20  # Adjust this gravity value as needed
		move_and_collide(velocity * _delta)
	if is_on_wall() and &"InRange":
		velocity.y = jump_power
	_post_physics_process.call_deferred()

func _post_physics_process() -> void:
	if not _moved_this_frame:
		velocity = lerp(velocity, Vector2.ZERO, 0.5)
	_moved_this_frame = false


func move(p_velocity: Vector2) -> void:
	velocity = lerp(velocity, p_velocity, 0.2)
	move_and_slide()
	_moved_this_frame = true


## Update agent's facing in the velocity direction.
func update_facing() -> void:
	_frames_since_facing_update += 1
	if _frames_since_facing_update > 3:
		face_dir(velocity.x)

## Face specified direction.
func face_dir(dir: float) -> void:
	if dir > 0.0:
		sprite.flip_h = false  # Face right
		hurtbox.scale.x = 1
		hitbox.scale.x = 1
		collision_shape_2d.disabled = false
		flipped_collision_shape_2d.disabled = true
		#collision_shape_2d.scale.x = 1
	elif dir < 0.0:
		sprite.flip_h = true   # Face left
		hurtbox.scale.x = -1
		hitbox.scale.x = -1
		flipped_collision_shape_2d.disabled = false
		collision_shape_2d.disabled = true
		#collision_shape_2d.scale.x = -1
	_frames_since_facing_update = 0

func get_facing() -> float:
	return -1.0 if sprite.flip_h else 1.0

func spit_projectile() -> void:
	var projectile := Projectile.instantiate()
	projectile.dir = get_facing()
	get_parent().add_child(projectile)
# Adjust spawn position to the character's center
	var offset_y = 20  # Change this value if the character's center isn't at `global_position.y`
	projectile.global_position = global_position + Vector2.RIGHT * get_facing() * 1.0 + Vector2(0, offset_y)



## Is specified position inside the arena (not inside an obstacle)?
func is_good_position(p_position: Vector2) -> bool:
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = p_position
	params.collision_mask = 1 # Obstacle layer has value 1
	var collision := space_state.intersect_point(params)
	return collision.is_empty()


## When agent is damaged...
func _damaged(_amount: float, knockback: Vector2) -> void:
	apply_knockback(knockback)
	animation_player.play(&"Hurt")
	var btplayer := get_node_or_null(^"BTPlayer") as BTPlayer
	if btplayer:
		btplayer.set_active(false)
	var hsm := get_node_or_null(^"LimboHSM")
	if hsm:
		hsm.set_active(false)
	await animation_player.animation_finished
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
	sprite.process_mode = Node.PROCESS_MODE_DISABLED
	animation_player.play("Death")
	#collision_shape_2d.set_deferred(&"disabled", true)
	#flipped_collision_shape_2d.set_deferred(&"disabled", true)
	self.collision_layer = 0
	self.collision_mask = 1
	for child in get_children():
		if child is BTPlayer or child is LimboHSM:
			child.set_active(false)

	if get_tree():
		await get_tree().create_timer(10.0).timeout
		queue_free()


func get_health() -> Health:
	return health
