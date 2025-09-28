extends Camera3D

@export var local_offset := Vector3(0.0, 2.5, 5.0)
@export var cam_target_offset := Vector3(0.0, 0.0, 1.0)
var cam_up := Vector3.UP

var linear_velocity := Vector3.ZERO
var angular_velocity := Vector3.ZERO

var new_basis:Basis = Basis.IDENTITY

@onready var p := get_parent() as Fermi


var cam_states:Dictionary[String, CamState] = {
	IDLE = load("res://scripts/entities/camera/cam_idle.gd").new(self, get_parent()),
	MOVING = load("res://scripts/entities/camera/cam_moving.gd").new(self, get_parent())
}

var state:CamState = cam_states.IDLE:
	set(value):
		state._exit_state()
		state = value

var x_prev := Vector3.ZERO
var y_prev := Vector3.ZERO
var m_jacobian := Basis.IDENTITY

func linear_constraint() -> Vector3:
	return p.transform.origin - transform.origin - get_distance_from_ground() * cam_up + basis * local_offset

func linear_constraint_2() -> Vector3:
	var distance_along_z := p.transform.origin.dot(p.basis.z) - transform.origin.dot(p.basis.z)
	if distance_along_z > 0:
		return p.transform.origin - transform.origin
	else:
		return Vector3.ZERO

func get_closest_level_point() -> Transform3D:
	if p.m_level_sections[0] == null:
		return Transform3D(Basis.IDENTITY, Vector3.UP)
	
	var path := p.m_level_sections[0].path as Path3D
	
	var path_forward := path.curve.get_closest_offset(p.transform.origin - path.transform.origin)
	var point := path.curve.sample_baked_with_rotation(path_forward)
	
	return point

func get_distance_from_ground() -> float:
	var parent:Fermi = get_parent()
	var ground_pos:float = get_closest_level_point().origin.dot(cam_up)
	var fermi_pos := parent.transform.origin.dot(cam_up)
	var final_pos := fermi_pos - ground_pos
	
	return final_pos

func get_cam_forward() -> Vector3:
	@warning_ignore("unused_variable")
	var path := p.m_level_sections[0].path as Path3D
	
	return Vector3.ZERO

func set_cam_position() -> void:
	linear_velocity = linear_constraint()

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
	
	
	#if p.m_state == p.m_states.idle:
		#state = cam_states.IDLE
	#else:
		#state = cam_states.MOVING
	
	state._process_state(delta)
	
	transform.origin += linear_velocity
	#new_basis = new_basis.rotated(angular_velocity.normalized(), angular_velocity.length())
	#basis = new_basis
	#look_at_from_position(transform.origin, p.transform.origin - 30.0 * p.basis.z\
	#,cam_up)
	
	angular_velocity -= angular_velocity * 24 * delta
	
	x_prev = transform.origin
	y_prev = linear_constraint()
