@tool
extends BTAction
## Dash horizontally toward the player's x position.

@export var target_var: StringName = &"target"
@export var dash_speed: float = 400.0
@export var arrival_tolerance: float = 8.0

func _generate_name() -> String:
	return "DashHorizontallyToPlayer"

func _tick(_delta: float) -> Status:
	var target: Node2D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var target_x: float = target.global_position.x
	var direction_x: float = sign(target_x - agent.global_position.x)
	agent.move(Vector2(direction_x * dash_speed, 0))
	agent.update_facing()

	if abs(agent.global_position.x - target_x) <= arrival_tolerance:
		return SUCCESS

	return RUNNING
