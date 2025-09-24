extends Node3D


@export var ground_positions:Array[Vector3] = []

@onready var path := $"Progress Spline"
@onready var bounding_box := $BoundingBox



func _on_player_entered(body) -> void:
	if not body is Fermi:
		return
	
	var p_level_sections := (body as Fermi).m_level_sections
	
	if p_level_sections.is_empty():
		p_level_sections.push_back(self)
	else:
		p_level_sections[1] = p_level_sections[0]
		p_level_sections[0] = self

func _on_player_exited(body) -> void:
	if not body is Fermi:
		return
	
	var p_level_sections := (body as Fermi).m_level_sections
	
	if p_level_sections.is_empty():
		printerr("Somehow, m_level_sections is empty, even though a level section
		should be present since we're in this function. \n
		This may be a good time to delete your git repository.")
		
		get_tree().root.close_requested.emit()
		## sudo rm -rf /
	else:
		p_level_sections[p_level_sections.find(self)] = null
		
		if p_level_sections[0] == null and p_level_sections[1] != null:
			p_level_sections[0] = p_level_sections[1]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bounding_box.body_entered.connect(_on_player_entered)
	bounding_box.body_exited.connect(_on_player_exited)
