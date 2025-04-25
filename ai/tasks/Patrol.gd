@tool
extends BTAction
## Enhanced patrol task: time-based movement between left and right patrol points.

@export var patrol_range: float = 200.0  # Default patrol range left/right
@export var patrol_time: float = 3.0  # Time (in seconds) to spend patrolling in one direction
@export var speed_var: StringName = &"speed"  # Blackboard key for patrol speed

const TOLERANCE := 10.0  # Distance threshold for reaching a point
var _target_point: Vector2  # Current target point
var _last_direction_right: bool = true  # Last direction (true = right, false = left)
var _elapsed_time: float = 0.0  # Tracks time spent in current patrol direction


# Generate a descriptive name for the task.
func _generate_name() -> String:
	return "Time-Based Patrol"


# Initialize patrol state and target point.
func _enter() -> void:
	_elapsed_time = 0.0
	_set_new_patrol_points()


# Main patrol logic.
func _tick(_delta: float) -> Status:
	# Check if the target is within 140 units
	var target = blackboard.get_var("target", null)
	if is_instance_valid(target):
		if agent.global_position.distance_to(target.global_position) <= 125.0:
			return FAILURE  # Interrupt patrol to allow higher-priority tasks

	# Update patrol timer
	_elapsed_time += _delta
	if _elapsed_time >= patrol_time:
		_elapsed_time = 0.0
		_set_new_patrol_points()  # Change direction after patrol_time

	# Move toward the current target point
	var speed: float = blackboard.get_var(speed_var, 100.0)
	var desired_velocity: Vector2 = agent.global_position.direction_to(_target_point) * speed
	agent.move(desired_velocity)
	agent.update_facing()
	return RUNNING


# Reset patrol state when the task exits.
func _exit() -> void:
	_elapsed_time = 0.0


# Dynamically calculate new patrol points around the current position.
func _set_new_patrol_points() -> void:
	var current_pos: Vector2 = agent.global_position
	if _last_direction_right:
		_target_point = current_pos + Vector2(patrol_range, 0)
	else:
		_target_point = current_pos - Vector2(patrol_range, 0)

	# Alternate direction
	_last_direction_right = !_last_direction_right
