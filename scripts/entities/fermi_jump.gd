class_name FermiJump
extends FermiState

var jump_entered:bool = true
var last_ground_position := Vector3.ZERO
var gravity_scale:float = 2.0
var gravity := 9.81

func _process_state(delta:float) -> void:
	if jump_entered:
		p_parent.m_speed.y = sqrt(2 * p_parent.m_max_jump_height * gravity * gravity_scale)
		p_parent.m_on_floor = false
		last_ground_position = p_parent.transform.origin
		jump_entered = false 
	
	var active_gravity_scale:float = gravity_scale * (1 if p_parent.m_speed.y > 0 else 1.5)
	
	p_parent.m_speed.y -= gravity * active_gravity_scale * delta
	var movement_vector = p_parent.camera.get_cam_local() * p_parent.input.get_movement_vector()
	
	
	p_parent.m_speed.z -= 24 * movement_vector.dot(-p_parent.basis.z) * delta
	p_parent.m_speed.x -= 8 * movement_vector.dot(-p_parent.basis.x) * delta
	
	p_parent.m_speed.z = clampf(p_parent.m_speed.z, -p_parent.m_max_speed_run, 0)
	
	
	if p_parent.m_on_floor and p_parent.input.get_movement_vector() != Vector3.ZERO:
		p_parent.set_state("walk")
	elif p_parent.m_on_floor:
		p_parent.set_state("idle")
	
func _exit_state() -> void:
	p_parent.m_speed *= Vector3(0, 0, 1)
	jump_entered = true
