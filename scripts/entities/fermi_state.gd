@abstract
class_name FermiState
extends Resource

var p_parent:Fermi

var cam_state:String

func _init(p_owner:Fermi) -> void:
	p_parent = p_owner
	_ready_state()

@abstract
func _ready_state() -> void

@abstract
func _process_state(delta:float) -> void

@abstract
func _exit_state() -> void
