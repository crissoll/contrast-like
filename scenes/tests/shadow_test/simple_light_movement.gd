extends Node

@onready var target : Node3D = get_parent()
@onready var initial_pos := target.global_position

var time := 0.0
func _physics_process(delta: float) -> void:
	time += delta
	target.global_position = initial_pos + sin(time) * Vector3(1,0.3,1)
