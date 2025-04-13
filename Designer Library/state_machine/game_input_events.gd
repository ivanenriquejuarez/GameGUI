class_name GameInputEvents
extends Node

static func movement_input() -> float:
	var direction : float = Input.get_axis("move_left","move_right")
	return direction

static func movement_input_y() -> float:
	var direction : float = Input.get_axis("move_up","move_down")
	return direction

static func jump_input()->bool:
	var jump_inputs : bool = Input.is_action_just_pressed("jump")
	return jump_inputs
	
static func control_input()->bool:
	var control_inputs : bool = Input.is_action_pressed("control")
	return control_inputs
	
static func attack1_input()->bool:
	var attack1_inputs : bool = Input.is_action_just_pressed("left_click")
	return attack1_inputs

static func attack2_input()->bool:
	var attack2_inputs : bool = Input.is_action_just_pressed("right_click")
	return attack2_inputs
	
static func shift_input()->bool:
	var shift_inputs : bool = Input.is_action_just_pressed("shift")
	return shift_inputs
