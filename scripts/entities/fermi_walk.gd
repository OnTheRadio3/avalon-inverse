class_name FermiWalk
extends FermiState



func _process_state(delta:float) -> void:
	p_parent.walk_from_input(delta)
	p_parent.rotate_from_input(delta)
	
	#var animRoot = p_parent.animTree["parameters/playback"]
	
	
	#print(p_parent.m_speed.z <= -p_parent.m_max_speed)
	if p_parent.m_speed.z <= -p_parent.m_max_speed:
		p_parent.set_state("run")
	
	if p_parent.input.is_jumping():
		p_parent.set_state("jump")
	
	if p_parent.m_speed.z == 0.0:
		p_parent.set_state("idle")
