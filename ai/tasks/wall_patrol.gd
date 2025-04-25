@tool
extends BTAction
## Wall-based patrol (walk): Move left or right until hitting a wall, then turn around after a delay.

@export var speed_var: StringName = &"speed"  # Patrol speed (used with `walk()`)
@export var turn_delay: float = 0.1  # Delay before turning around after wall hit

var _last_direction_right: bool = true
var _turning: bool = false
var _turn_timer: float = 0.0


func _generate_name() -> String:
	return "Wall Patrol (Walk Only)"


func _enter() -> void:
	_last_direction_right = blackboard.get_var("last_direction_right", true)
	_turning = false
	_turn_timer = 0.0


func _tick(delta: float) -> Status:
	# Check if a valid target exists and is close enough to stop patrolling
	var target = blackboard.get_var("target", null)
	if is_instance_valid(target):
		if agent.global_position.distance_to(target.global_position) <= 160.0:
			return FAILURE  # Let the tree move to attack or chase

	# Normal patrol logic follows
	if _turning:
		_turn_timer += delta
		if _turn_timer >= turn_delay:
			_turning = false
			_turn_timer = 0.0
			_last_direction_right = !_last_direction_right

	if not _turning:
		var speed: float = blackboard.get_var(speed_var, 100.0)
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
