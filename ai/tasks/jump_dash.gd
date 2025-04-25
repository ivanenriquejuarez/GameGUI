extends BTAction

@export var dash_speed: float = 400.0
@export var jump_speed: float = -300.0
@export var timeout: float = 1.0
@export var target_var: StringName = "target"

var _phase := 0
var _timer := 0.0
var _target_pos: Vector2

func _generate_name() -> String:
	return "JumpDash"

func _enter() -> void:
	var target = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		_phase = -1
		return

	_target_pos = target.global_position
	_phase = 0
	_timer = 0.0
	agent.gravity_scale = 0  # Disable gravity at start

func _tick(delta: float) -> Status:
	if _phase == -1:
		return FAILURE

	# Phase 0: Try to dash directly to target position
	if _phase == 0:
		var direction = (_target_pos - agent.global_position).normalized()
		agent.velocity = direction * dash_speed
		agent.move_and_slide()

		_timer += delta
		if agent.global_position.distance_to(_target_pos) < 16:
			return SUCCESS
		elif _timer >= timeout:
			_phase = 1  # Move to jump phase
			_timer = 0.0

	# Phase 1: Jump upward until above the target
	elif _phase == 1:
		if agent.global_position.y > _target_pos.y - 8.0:
			agent.velocity = Vector2(0, jump_speed)
			agent.move_and_slide()
		else:
			_phase = 2  # Now dash horizontally

	# Phase 2: Dash toward the player's X position
	elif _phase == 2:
		var target_x = _target_pos.x
		var direction = sign(target_x - agent.global_position.x)
		agent.velocity = Vector2(direction * dash_speed, 0)
		agent.move_and_slide()

		if abs(agent.global_position.x - target_x) < 8:
			return SUCCESS

	return RUNNING

func _exit() -> void:
	agent.gravity_scale = 1  # Re-enable gravity on exit
	agent.velocity = Vector2.ZERO
