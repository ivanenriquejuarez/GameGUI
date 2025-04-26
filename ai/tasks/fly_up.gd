@tool
extends BTAction

## Moves the agent upwards. [br]
## Returns [code]RUNNING[/code] always.

## Blackboard variable that stores desired upward speed.
@export var speed_var: StringName = &"upward_speed"

## How much the upward direction can deviate (in radians).
@export var max_angle_deviation: float = 0.3

var _dir: Vector2 = Vector2.UP
var _desired_velocity: Vector2

# Called each time this task is entered.
func _enter() -> void:
	# Determine the upward direction and calculate the desired velocity
	var speed: float = blackboard.get_var(speed_var, 150.0)  # Default to 150 if not set
	var rand_angle = randf_range(-max_angle_deviation, max_angle_deviation)
	_desired_velocity = _dir.rotated(rand_angle) * speed

# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	agent.move(_desired_velocity)
	return RUNNING
