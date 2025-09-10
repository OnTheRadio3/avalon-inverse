class_name Fermi
extends CharacterBody3D

var m_states:Dictionary[String, FermiState] = {
	idle = FermiIdle.new(self),
	walk = FermiWalk.new(self),
	jump = FermiJump.new(self)
}
var m_state:FermiState = m_states.walk:
	set(value):
		if m_state != null:
			m_state._exit_state()
		m_state = value

var m_x_speed:float = 0.0
var m_y_speed:float = 0.0

var m_on_floor:bool = false

@onready var input:InputHandler = $InputHandler
@onready var camera:Camera3D = $Camera3D

@export var m_acceleration := 12.0
@export var m_max_speed := 5.0
@export var m_damping := 6.0
@export var m_max_jump_height := 5.0
@export var m_turn_speed:float = 6.0

func collide_and_slide(vel:Vector3) -> void:
	var collision_result = move_and_collide(vel)
	var floor_collisions:int = 0
	
	for i in 8:
		if collision_result:
			floor_collisions += 1
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

func turn(angle:float) -> void:
	rotate_y(angle)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if m_state:
		m_state._process_state(delta)
	
	print(input.get_state_vector())
	
	var movement_vector := camera.basis * input.get_movement_vector()
	
	collide_and_slide( (m_x_speed * -basis.z + (m_y_speed + -9.8) * Vector3.UP) * delta)
