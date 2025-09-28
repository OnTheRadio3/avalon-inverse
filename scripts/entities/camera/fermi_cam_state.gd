@abstract
class_name CamState
extends RefCounted

var p_parent:Camera3D
var p:Fermi

func _init(p_owner:Camera3D, p_player:Fermi) -> void:
	p_parent = p_owner
	p = p_player

func set_cam_position() -> void:
	p_parent.linear_velocity = p_parent.linear_constraint()

func apply_cam_linear_constraint_2(delta:float) -> void:
	p_parent.linear_velocity += p_parent.linear_constraint_2() * delta

func set_cam_orientation(rotation_speed:float, delta:float) -> void:
	var orientation = Basis.looking_at(
		p_parent.p.transform.origin - p_parent.basis * p_parent.cam_target_offset,
		p_parent.cam_up)
	
	
	p_parent.basis = p_parent.basis.slerp(orientation, 1.0 - pow(0.5, delta * rotation_speed))

@abstract
func _exit_state() -> void

@abstract
func _process_state(delta:float) -> void
