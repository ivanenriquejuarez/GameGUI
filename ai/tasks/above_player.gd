@tool
extends BTAction
## Jump slightly forward and upward until above the player's Y position.

@export var target_var: StringName = &"target"
@export var jump_speed: float = -300.0
@export var horizontal_push: float = 50.0
@export var y_offset: float = 8.0

func _generate_name() -> String:
	return "JumpAbovePlayer"

func _tick(_delta: float) -> Status:
	var target: Node2D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var direction_x: float = 0.0
	if agent.global_position.x < target.global_position.x:
		direction_x = horizontal_push
	elif agent.global_position.x > target.global_position.x:
		direction_x = -horizontal_push

	if agent.global_position.y > target.global_position.y - y_offset:
		agent.move(Vector2(direction_x, jump_speed))
		return RUNNING

	return SUCCESS
