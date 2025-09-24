class_name FermiIdle
extends FermiState

func _process_state(delta:float) -> void:
	p_parent.rotate_to_input_direction()
	
	if p_parent.input.get_movement_vector() != Vector3.ZERO or p_parent.m_speed.z != 0.0:
		p_parent.m_state = p_parent.m_states.walk
	
	if p_parent.input.is_jumping():
		p_parent.m_state = p_parent.m_states.jump
	
func _exit_state() -> void:
	return
