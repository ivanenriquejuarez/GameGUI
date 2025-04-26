@tool
extends BTAction

## Minimum distance to the desired position.
@export var range_min: float = 300.0

## Maximum distance to the desired position.
@export var range_max: float = 500.0

## Blackboard variable that will be used to store the desired position.
@export var position_var: StringName = &"pos"

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "SelectRandomAbovePos  range: [%s, %s]  ➜%s" % [
		range_min, range_max,
		LimboUtility.decorate_var(position_var)
	]

# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	var pos: Vector2
	var is_good_position: bool = false

	while not is_good_position:
		# Generate a random angle within the semicircle above (π radians)
		var angle: float = randf() * PI
		# Randomize distance within the specified range
		var rand_distance: float = randf_range(range_min, range_max)
		# Calculate the position using polar coordinates
		pos = agent.global_position + Vector2(cos(angle), -sin(angle)) * rand_distance
		# Ensure the position is valid
		is_good_position = agent.is_good_position(pos)

	# Store the valid position in the blackboard
	blackboard.set_var(position_var, pos)
	return SUCCESS
