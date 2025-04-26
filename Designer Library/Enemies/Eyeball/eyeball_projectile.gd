#*
#* fireball.gd
#* =============================================================================
#* Copyright 2021-2024 Serhii Snitsaruk
#*
#* Use of this source code is governed by an MIT-style
#* license that can be found in the LICENSE file or at
#* https://opensource.org/licenses/MIT.
#* =============================================================================
#*
extends Node2D
## projectile

const SPEED := 100.0
const DEAD_SPEED := 50.0

@export var dir: float = 1.0

var _is_dead: bool = false
@onready var projectile: Sprite2D = $Root/projectile
#@onready var collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var root: Node2D = $Root
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(projectile, ^"rotation", PI * signf(dir), 1.0).as_relative()

	var tween2 := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween2.tween_property(projectile, "position:y", -10.0, 0.5).as_relative().set_ease(Tween.EASE_OUT)
	tween2.tween_property(projectile, "position:y", 0.0, 1.0)
	tween2.tween_callback(_die)


func _physics_process(delta: float) -> void:
	var speed: float = SPEED if not _is_dead else DEAD_SPEED
	position += Vector2.RIGHT * speed * dir * delta


func _die() -> void:
	if _is_dead:
		return
	_is_dead = true
	animation_player.play("Death")
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	#collision_shape_2d.set_deferred(&"disabled", true)
	#await animation_player.finished

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Death":
		# After the death animation finishes, hide and free the node
		root.hide()
		queue_free()

func _on_hitbox_area_entered(_area: Area2D) -> void:
	_die()
