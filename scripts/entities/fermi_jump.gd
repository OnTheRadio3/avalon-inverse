class_name FermiJump
extends FermiState

var jump_entered:bool = true

func _process_state(delta:float) -> void:
	if jump_entered:
		p_parent.m_speed.y += p_parent.m_max_jump_height
		p_parent.m_on_floor = false
		jump_entered = false 
	
	p_parent.m_speed.y -= 9.81 * 2 * delta
	
	var movement_vector = p_parent.camera.get_cam_local() * p_parent.input.get_movement_vector()
	
	
	p_parent.m_speed.z -= 8 * movement_vector.dot(-p_parent.basis.z) * delta
	p_parent.m_speed.x -= 8 * movement_vector.dot(-p_parent.basis.x) * delta
	
	if p_parent.m_on_floor:
		p_parent.m_state = p_parent.m_states.idle
	
func _exit_state() -> void:
	p_parent.m_speed = Vector3.ZERO
	jump_entered = true
