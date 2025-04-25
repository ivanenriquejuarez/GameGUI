@tool
extends BTAction
## Wall-based patrol (run): Move left or right until hitting a wall, then turn around after a delay.
## Only runs while the player is in range.

@export var charge_speed_var: StringName = &"charge_speed"  # Run speed
@export var turn_delay: float = 0.01  # Delay before turning around after wall hit

var _last_direction_right: bool = true
var _turning: bool = false
var _turn_timer: float = 0.0


func _generate_name() -> String:
	return "Wall Patrol (Run Only)"


func _enter() -> void:
	_last_direction_right = blackboard.get_var("last_direction_right", true)
	_turning = false
	_turn_timer = 0.0


func _tick(delta: float) -> Status:
	# Stop running if player is NOT in range
	var target = blackboard.get_var("target", null)
	var distance = agent.global_position.distance_to(target.global_position)
	if distance > 160.0 or distance < 50.0:
		return FAILURE  # Exit run patrol if too far or too close

	# Normal run patrol logic
	if _turning:
		_turn_timer += delta
		if _turn_timer >= turn_delay:
			_turning = false
			_turn_timer = 0.0
			_last_direction_right = !_last_direction_right

	if not _turning:
		var speed: float = blackboard.get_var(charge_speed_var, 200.0)
		var direction: float = 1.0 if _last_direction_right else -1.0
		agent.walk(direction, speed)

		if agent.is_on_wall():
			_turning = true

	blackboard.set_var("last_direction_right", _last_direction_right)
	agent.update_facing()

	return RUNNING


func _exit() -> void:
	_turn_timer = 0.0
	_turning = false
