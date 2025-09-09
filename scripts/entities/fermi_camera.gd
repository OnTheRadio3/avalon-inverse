extends Camera3D

var local_offset := Vector3(0.0, 2.5, 5.0)
@export var camera_rotation_offset := Vector3(-5.0, 0.0, 0.0)


func get_cam_local() -> Basis:
	return basis.rotated(basis.x, -camera_rotation_offset.x * PI/180)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_level = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#basis = basis.slerp(get_parent().basis, 1.0 - pow(0.5, 12 * delta))
	
	basis = Basis.from_euler(camera_rotation_offset * PI/180)
	transform.origin = get_parent().transform.origin + local_offset
