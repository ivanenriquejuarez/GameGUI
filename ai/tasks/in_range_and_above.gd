@tool
extends BTCondition
## Checks if the player is within range AND above the agent.

@export var distance_min: float = 0.0
@export var distance_max: float = 150.0
@export var y_threshold: float = 32.0  # How much higher counts as "above"
@export var target_var: StringName = &"target"

var _min_distance_squared: float
var _max_distance_squared: float

func _generate_name() -> String:
	return "InRangeAndAbove (%d, %d, y>%d) of %s" % [
		distance_min, distance_max, y_threshold,
		LimboUtility.decorate_var(target_var)
	]

func _setup() -> void:
	_min_distance_squared = distance_min * distance_min
	_max_distance_squared = distance_max * distance_max

func _tick(_delta: float) -> Status:
	var target: Node2D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var dist_sq: float = agent.global_position.distance_squared_to(target.global_position)
	var is_above: bool = target.global_position.y < agent.global_position.y - y_threshold
	var is_on_floor: bool = agent.is_on_floor()

	if dist_sq >= _min_distance_squared and dist_sq <= _max_distance_squared and is_above and is_on_floor:
		return SUCCESS
	else:
		return FAILURE
