@tool
extends BTCondition
## Returns SUCCESS if the enemy should attack, otherwise FAILURE.

@export var attack_chance: float = 0.01
@export var cooldown: float = 1.5
@export var last_attack_time_key: StringName = &"last_attack_time"

func _generate_name() -> String:
	return "ShouldAttack (%.2f%% chance)" % [attack_chance * 100.0]

func _tick(_delta: float) -> Status:
	var current_time = Time.get_ticks_msec() / 1000.0
	var last_time = blackboard.get_var(last_attack_time_key, 0.0)

	if current_time - last_time >= cooldown:
		if randf() < attack_chance:
			blackboard.set_var(last_attack_time_key, current_time)
			return SUCCESS

	return FAILURE
