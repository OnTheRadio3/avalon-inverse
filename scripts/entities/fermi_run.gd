extends FermiState
class_name FermiRun

func _ready_state() -> void:
	cam_state = "MOVING"

func _exit_state() -> void:
	pass

func _process_state(delta:float) -> void:
	p_parent.run_from_input(delta)
	p_parent.rotate_from_input(delta)
	
	p_parent.apply_gravity(delta)
	
	if p_parent.input.is_jumping():
		p_parent.set_state("jump")
	
	
	if p_parent.input.get_movement_vector() == Vector3.ZERO:
		p_parent.set_state("walk")
