class_name FermiState
extends Resource

var p_parent:Fermi

func _init(p_owner:Fermi) -> void:
	p_parent = p_owner

func _process_state(delta:float) -> void:
	pass
	
func _exit_state() -> void:
	pass
