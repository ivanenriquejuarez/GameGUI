extends BTAction

@export var charge_speed_var: StringName = &"charge_speed"
@export var speed_var: StringName = &"speed"
@export var powered_up_flag: StringName = &"powered_up"

const CHARGE_MAX := 250.0
const SPEED_MAX := 140.0

func _tick(_delta: float) -> Status:
	var charge_speed: float = blackboard.get_var(charge_speed_var, 0.0)
	charge_speed = min(charge_speed + 25, CHARGE_MAX)
	blackboard.set_var(charge_speed_var, charge_speed)

	var speed: float = blackboard.get_var(speed_var, 0.0)
	speed = min(speed + 10, SPEED_MAX)
	blackboard.set_var(speed_var, speed)

	var powered_up := charge_speed >= CHARGE_MAX and speed >= SPEED_MAX
	blackboard.set_var(powered_up_flag, powered_up)  # true or false
	#print("speed up:", speed)
	#print("chargespeed up:", charge_speed)
	#print("Powered up:", powered_up)
	
	return SUCCESS
