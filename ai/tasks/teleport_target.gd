@tool
extends BTAction
## Fades out the agent, teleports to a destination Area2D, then fades back in.

@export var destination_var: StringName = &"teleport_target"  # Blackboard var holding the Area2D
@export var fade_duration: float = 0.5  # How long to fade out/in

var _phase := 0
var _timer := 0.0
var _sprite: CanvasItem
var _destination: Node2D


func _generate_name() -> String:
	return "TeleportFadeTo %s" % LimboUtility.decorate_var(destination_var)


func _enter() -> void:
	_destination = blackboard.get_var(destination_var, null)
	if not is_instance_valid(_destination):
		_phase = -1
		return

	_sprite = agent.get_node_or_null("Sprite2D")  # or your sprite path
	if _sprite:
		_sprite.modulate.a = 1.0  # start fully visible

	_phase = 0
	_timer = 0.0


func _tick(delta: float) -> Status:
	if _phase == -1:
		return FAILURE

	match _phase:
		# Phase 0: Fade out
		0:
			_timer += delta
			if _sprite:
				_sprite.modulate.a = 1.0 - (_timer / fade_duration)

			if _timer >= fade_duration:
				_sprite.modulate.a = 0.0
				agent.global_position = _destination.global_position
				_phase = 1
				_timer = 0.0

		# Phase 1: Fade in
		1:
			_timer += delta
			if _sprite:
				_sprite.modulate.a = (_timer / fade_duration)

			if _timer >= fade_duration:
				_sprite.modulate.a = 1.0
				return SUCCESS

	return RUNNING


func _exit() -> void:
	if _sprite:
		_sprite.modulate.a = 1.0  # Ensure full visibility on exit
