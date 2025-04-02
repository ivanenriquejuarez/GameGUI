extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera2D = $Camera2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var _moved_this_frame: bool = false
var _is_dead: bool = false
@export_category("Camera Settings")
@export var left: int = -10000000
@export var right: int = 10000000
@export var top: int = -10000000
@export var bottom: int = 10000000
@export var camera_zoom_x: float = 3.0
@export var camera_zoom_y: float = 3.0
@export var camera_x_transform: float = 0
@export var camera_y_transform: float = 0 
@export var inventory: Inventory
@export var base_damage: int = 0

var reward_node = get_node
func _ready() -> void:
	camera.limit_bottom = bottom
	camera.limit_top = top
	camera.limit_left = left
	camera.limit_right = right
	camera.zoom.x = camera_zoom_x
	camera.zoom.y = camera_zoom_y
	camera.position.x = camera_x_transform
	camera.position.y = camera_y_transform
	SaveController.connect("PotionAdded", Callable(self, "_on_potion_added"))
	
## When agent is damaged...
func _damaged(_amount: float, knockback: Vector2) -> void:
	apply_knockback(knockback)
	#animation_player.play(&"hurt")
	var btplayer := get_node_or_null(^"BTPlayer") as BTPlayer
	if btplayer:
		btplayer.set_active(false)
	var hsm := get_node_or_null(^"LimboHSM")
	if hsm:
		hsm.set_active(false)
	#await animation_player.animation_finished
	if btplayer and not _is_dead:
		btplayer.restart()
	if hsm and not _is_dead:
		hsm.set_active(true)

#func receives_knockback(damage_source_pos: Vector2, received_damage: int):
	#pass
func apply_knockback(knockback: Vector2, frames: int = 10) -> void:
	if knockback.is_zero_approx():
		return
	for i in range(frames):
		move(knockback)
		await get_tree().physics_frame

func move(p_velocity: Vector2) -> void:
	velocity = lerp(velocity, p_velocity, 0.2)
	move_and_slide()
	_moved_this_frame = true

func get_facing() -> float:
	return 1

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.has_method("collect"):
		area.collect(inventory)
		
func _on_potion_added() -> void:
	update_damage()
	update_health()
	update_stamina()
	update_speed()
	update_jump()
	
func update_damage() -> void:
	var strPotions = SaveController.getPotionCount("Elixir of Strength")
	$Sprite2D/Hitbox.damage = $Sprite2D/Hitbox.damage + strPotions
	$Sprite2D/LightHitbox.damage = $Sprite2D/LightHitbox.damage + strPotions

func update_health() -> void:
	var healthPotions = SaveController.getPotionCount("Elixir of Fortitude")
	$Health.max_health = $Health.max_health + 2*(healthPotions)
	var current_health = $Health.get_current()+2
	$Camera2D/StatusUI.set_max_health($Health.max_health)
	$Camera2D/StatusUI.update_health(current_health)
	
func update_stamina() -> void:
	var staminaPotions = SaveController.getPotionCount("Elixir of Stamina")
	$Stamina.max_stamina = $Stamina.max_stamina + staminaPotions
	
	
func update_speed() -> void:
	var speedPotions = SaveController.getPotionCount("Elixir of Swiftness")
	if speedPotions > 0:
		$StateMachine/Run.speed *= (1.1 ** speedPotions)
		$StateMachine/Run.max_horizontal_speed *= (1.1 ** speedPotions)
	
func update_jump() -> void:
	var jumpPotions = SaveController.getPotionCount("Elixir of Jumping")
	if jumpPotions > 0:
		$StateMachine/Jump.jump_power *= (1.1 ** jumpPotions)
