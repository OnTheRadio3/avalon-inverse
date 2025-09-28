class_name Fermi
extends CharacterBody3D

@export var m_states:Dictionary[String, FermiState] = {
	idle = FermiIdle.new(self),
	walk = FermiWalk.new(self),
	run = FermiRun.new(self),
	jump = FermiJump.new(self)
}
var m_state:FermiState = m_states.walk:
	set(value):
		if m_state != null:
			m_state._exit_state()
		$Camera3D.state = $Camera3D.cam_states[value.cam_state]
		m_state = value

var m_level_sections:Array[Node3D] = [null, null]

var m_speed := Vector3.ZERO

var m_on_floor:bool = false

@onready var input:InputHandler = $InputHandler
@onready var camera:Camera3D = $Camera3D
@onready var animTree := $AnimationTree

@export_category("Walk Parameters")
@export var m_acceleration := 4.0
@export var m_deceleration := 6.0
@export var m_max_speed := 5.0
@export var m_damping := 6.0

@export_category("Run Parameters")
@export var m_acceleration_run := 12.0
@export var m_deceleration_run := 16.0
@export var m_max_speed_run := 10.0
@export var m_damping_run := 6.0

@export_category("")
@export var m_max_jump_height := 5.0
@export var m_turn_speed:float = 6.0


func set_state(state:StringName) -> void:
	m_state = m_states[state]

func check_state(state:StringName) -> bool:
	return m_states.has(state) and m_states[state] == m_state

func collide_and_slide(vel:Vector3) -> void:
	var collision_result = move_and_collide(vel)
	var floor_collisions:int = 0
	
	for i in 8:
		if collision_result:
			floor_collisions += 1
			m_speed = m_speed.slide(collision_result.get_normal())
			vel = vel.slide(collision_result.get_normal())
			collision_result = move_and_collide(vel)
		else:
			if i == 0:
				floor_collisions = 0
			break
	
	m_on_floor = floor_collisions > 0

func raycast(from:Vector3, to:Vector3) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var ray_params := PhysicsRayQueryParameters3D.create(from, from + to)
	
	return space_state.intersect_ray(ray_params)

func check_floor() -> bool:
	return !raycast(transform.origin, -0.01 * basis.y).is_empty()

func apply_gravity(delta:float):
	#if !check_floor():
		#return
	
	m_speed.y -= 9.81 * delta

func turn(angle:float) -> void:
	rotate_y(angle)

func rotate_from_input(delta:float) -> void:
	var movement_input = input.get_movement_vector().normalized()
	var local_to_cam:Basis = camera.get_cam_local()
	
	if movement_input != Vector3.ZERO:
		var angle:float = basis.z.signed_angle_to(local_to_cam * -movement_input, basis.y)
		
		if absf(angle) < PI - 0.1:
			turn(angle * delta * m_turn_speed)
		else:
			turn(angle)

func rotate_to_input_direction() -> void:
	var movement_input = input.get_movement_vector().normalized()
	var local_to_cam:Basis = camera.get_cam_local()
	
	if movement_input != Vector3.ZERO:
		var angle:float = basis.z.signed_angle_to(local_to_cam * -movement_input, basis.y)
		turn(angle * get_physics_process_delta_time() * 12)


func walk_from_input(delta:float) -> void:
	var movement_input := input.get_movement_vector().normalized()
	
	if movement_input != Vector3.ZERO:
		m_speed.z -= (m_acceleration + m_speed.z * m_damping) * delta
	else:
		m_speed.z += (m_deceleration - m_speed.z * m_damping) * delta
	
	m_speed.z = clampf(m_speed.z, -m_max_speed, 0)

func run_from_input(delta:float) -> void:
	var movement_input := input.get_movement_vector().normalized()
	
	if movement_input != Vector3.ZERO:
		m_speed.z -= (m_acceleration_run + m_speed.z * m_damping_run) * delta
	else:
		m_speed.z += (m_deceleration_run - m_speed.z * m_damping_run) * delta
	
	
	m_speed.z = clampf(m_speed.z, -m_max_speed_run, 0)
	#print(m_speed.z)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if m_state:
		m_state._process_state(delta)
	
	#print(input.get_state_vector())
	
	#region Debug positional constraints
	
	if transform.origin.y < -50:
		transform.origin = Vector3.ZERO
		m_speed = Vector3.ZERO
	#endregion
	
	collide_and_slide(basis * m_speed * delta)
