class_name FermiWalk
extends FermiState


func _process_state(delta:float) -> void:
	var movement_input := p_parent.input.get_movement_vector().normalized()
	
	if movement_input != Vector3.ZERO:
		p_parent.m_speed.z = -p_parent.m_max_speed
	else:
		p_parent.m_speed.z += (p_parent.m_acceleration - p_parent.m_speed.z * p_parent.m_damping) * delta
	
	p_parent.m_speed.z = clampf(p_parent.m_speed.z, -p_parent.m_max_speed, 0)
	print(p_parent.m_speed.z)
	
	var local_to_cam:Basis = p_parent.camera.get_cam_local()
	
	if movement_input != Vector3.ZERO:
		var angle:float = p_parent.basis.z.signed_angle_to(local_to_cam * -movement_input, p_parent.basis.y)
		#print(angle, " ", movement_input)
		p_parent.turn(angle)
		
	if p_parent.input.is_jumping():
		p_parent.m_state = p_parent.m_states.jump
	
	if p_parent.m_speed.z == 0.0:
		p_parent.m_state = p_parent.m_states.idle
