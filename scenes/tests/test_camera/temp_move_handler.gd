extends Node3D

@onready 
var camera_system: CompCameraHandler = $"../CameraHandler"
@onready 
var player: CharacterBody3D = $".."

@export
var move_speed : float = 100.0

var acceleration := 40.0
var cur_speed : float = 0.0

func _physics_process(delta: float) -> void:
	var move_vector := Input.get_vector(
		&"move_left",
		&"move_right",
		&"move_forward",
		&"move_backward"
	)
	
	if(move_vector.length() < 0.1):
		cur_speed = 0
	elif cur_speed < move_speed:
		cur_speed += acceleration * delta
	
	if player.is_on_floor():
		player.velocity = cur_speed * (
			move_vector.x * camera_system.basis.x +
		 	move_vector.y * camera_system.basis.z * Vector3(1,0,1)	
		) +player.velocity * Vector3.UP
	else:
		player.velocity.y -= 10.0 * delta
	
	player.move_and_slide()
