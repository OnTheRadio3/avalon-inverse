extends Camera3D

var local_offset := Vector3(0.0, 2.2, 5.0)
@export var camera_rotation_offset := Vector3(-5.0, 0.0, 0.0)
var cam_up := Vector3.UP

var linear_velocity := Vector3.ZERO
var angular_velocity := Vector3.ZERO

var new_basis:Basis = Basis.IDENTITY

var active_state := 0

const CAM_STATIC := 0
const CAM_MOVING := 1
const CAM_JUMPING := 2

var cam_states:Array[Callable] = [set_cam_static, set_cam_moving]

@onready var p := get_parent() as Fermi


var x_prev := Vector3.ZERO
var y_prev := Vector3.ZERO
var m_jacobian := Basis.IDENTITY

func linear_constraint() -> Vector3:
	return p.transform.origin - transform.origin - get_distance_from_ground() * cam_up + get_cam_local() * local_offset

func get_closest_level_point() -> Transform3D:
	var p := get_parent() as Fermi
	
	if p.m_level_sections[0] == null:
		return Transform3D.IDENTITY
	
	var path := p.m_level_sections[0].path as Path3D
	
	var path_forward := path.curve.get_closest_offset(p.transform.origin - path.transform.origin)
	var point := path.curve.sample_baked_with_rotation(path_forward)
	#point.origin += path.origin
	
	return point

func get_distance_from_ground() -> float:
	var parent:Fermi = get_parent()
	var ground_pos:float = get_closest_level_point().origin.dot(cam_up)
	var fermi_pos := parent.transform.origin.dot(cam_up)
	var final_pos := fermi_pos - ground_pos
	
	return final_pos

func get_cam_forward() -> Vector3:
	var p := get_parent_node_3d() as Fermi
	var path := p.m_level_sections[0].path as Path3D
	
	return Vector3.ZERO
	#path.curve.

func set_cam_position() -> void:
	linear_velocity = linear_constraint()

func set_cam_orientation(delta:float) -> void:
	var p = get_parent() as Fermi
	#var orientation := get_closest_level_point().basis
	var orientation = p.basis
	var level_orientation := get_closest_level_point().basis
	var angle:float = orientation.z.signed_angle_to(new_basis.z, orientation.y)
	var lerp_speed:float = min(absf(angle), 1.0 - pow(0.5, 2.0 * delta)) * -sign(angle)
	
	#print(angle > absf(1.0 - pow(0.5, 2.0 * delta)))
	
	#\
	#- absf(level_orientation.z.signed_angle_to(new_basis.z, level_orientation.y)) * 2
	
	new_basis = new_basis.rotated(orientation.y, lerp_speed)
	
	basis = new_basis# * Basis.from_euler(camera_rotation_offset * PI/180)
	

func set_cam_static(delta:float) -> void:
	set_cam_moving(delta)

func set_cam_moving(delta:float) -> void:
	var parent = get_parent()
	
	set_cam_orientation(delta)
	set_cam_position()

## Deprecated
func cam_position_jumping() -> void:
	var parent:Fermi = get_parent()
	var ground_pos:float = parent.m_states.jump.last_ground_position.dot(cam_up)
	var fermi_pos := parent.transform.origin.dot(cam_up)
	var final_pos := parent.transform.origin - fermi_pos * cam_up
	var t := clampf((fermi_pos - ground_pos) / parent.m_max_jump_height, 0.0, 1.0)
	
	final_pos += lerpf(ground_pos, fermi_pos, t) * cam_up
	
	transform.origin = final_pos + local_offset


func get_cam_local() -> Basis:
	var true_y := (get_parent() as Fermi).basis.y
	
	var r_basis := Basis.IDENTITY
	r_basis.x = basis.x.slide(true_y).normalized()
	r_basis.z = basis.z.slide(true_y).normalized()
	r_basis.y = true_y
	
	return r_basis

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_level = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var d := transform.origin - x_prev
	var df := linear_constraint() - y_prev
	
	
	m_jacobian.x = Vector3(d.x / df.x, d.x / df.y, d.x / df.z)
	m_jacobian.y = Vector3(d.y / df.x, d.y / df.y, d.y / df.z)
	m_jacobian.z = Vector3(d.z / df.x, d.y / df.y, d.z / df.z)
	
	
	if p.m_speed == Vector3.ZERO:
		active_state = CAM_STATIC
	else:
		active_state = CAM_MOVING
	
	transform.origin += linear_velocity
	
	cam_states[active_state].call(delta)
	x_prev = transform.origin
	y_prev = linear_constraint()
