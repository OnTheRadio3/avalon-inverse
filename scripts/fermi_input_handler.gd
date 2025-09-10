class_name InputHandler
extends Node

@export var device_number = 0
@export var controller_mode:bool = false

var m_left_stick := Vector3.ZERO
var m_jump_state:PackedByteArray = [0]
var m_attack_state:PackedByteArray = [0]
var m_start_state:bool = false
var m_select_state:bool = false

@export_category("Input Bindings")
@export var kb_inputs:Dictionary[Key, Callable] = {
	KEY_W: forward_action,
	KEY_S: backward_action,
	KEY_A: left_action,
	KEY_D: right_action,
	KEY_J: jump_action,
	KEY_K: attack_action,
	KEY_ENTER: start_action,
	KEY_SHIFT: select_action
}

## Joystick inputs need their own hashmap due to conflicting key values
## (JOY_AXIS_LEFT_Y == JOY_BUTTON_A)
@export var controller_joy_inputs:Dictionary[JoyAxis, Callable] = {
	JOY_AXIS_LEFT_Y: stick_forward_action,
	JOY_AXIS_LEFT_X: stick_sideways_action
}

@export var controller_inputs:Dictionary[JoyButton, Callable] = {
	JOY_BUTTON_A: jump_action,
	JOY_BUTTON_B: attack_action,
	JOY_BUTTON_START: start_action,
	JOY_BUTTON_BACK: select_action
}


func is_start_pressed() -> bool:
	return m_start_state

func is_select_pressed() -> bool:
	return m_select_state

func is_jumping() -> bool:
	return m_jump_state.decode_u8(0) > 0
	
func is_attacking() -> bool:
	return m_attack_state.decode_u8(0) > 0

func is_jump_held() -> bool:
	return m_jump_state.decode_u8(0) > 1

func is_attack_held() -> bool:
	return m_attack_state.decode_u8(0) > 1

func get_movement_vector() -> Vector3:
	return m_left_stick

func get_state_vector() -> Array:
	return [m_jump_state, m_attack_state, m_left_stick]



func _unhandled_input(event: InputEvent) -> void:
	if event.device != device_number:
		return
	
	if not event is InputEventKey and not controller_mode:
		return
	
	if not kb_inputs.has(event.keycode):
		return
	
	var key_func = kb_inputs.get(event.keycode)
	key_func.call(event)

func start_action(event:InputEvent) -> void:
	m_start_state = event.pressed

func select_action(event:InputEvent) -> void:
	m_select_state = event.pressed

func jump_action(event:InputEvent) -> void:
	m_jump_state.encode_u8(0, int(event.pressed) * (int(is_jumping()) + 1) )

func attack_action(event:InputEvent) -> void:
	m_attack_state.encode_u8(0, int(event.pressed) * (int(is_attacking()) + 1) )

func forward_action(event:InputEvent) -> void:
	m_left_stick.z -= 1 * int(event.pressed) * int(m_left_stick.z > -1)\
	 - int(event.is_released()) * int(m_left_stick.z != 0)

func backward_action(event:InputEvent) -> void:
	m_left_stick.z += 1 * int(event.pressed) * int(m_left_stick.z < 1)\
	 - int(event.is_released()) * int(m_left_stick.z != 0)

func left_action(event:InputEvent) -> void:
	m_left_stick.x -= 1 * int(event.pressed) * int(m_left_stick.x > -1)\
	 - int(event.is_released()) * int(m_left_stick.x != 0)

func right_action(event:InputEvent) -> void:
	m_left_stick.x += 1 * int(event.pressed) * int(m_left_stick.x < 1)\
	 - int(event.is_released()) * int(m_left_stick.x != 0)

func stick_forward_action(event:InputEvent) -> void:
	pass

func stick_sideways_action(event:InputEvent) -> void:
	pass
