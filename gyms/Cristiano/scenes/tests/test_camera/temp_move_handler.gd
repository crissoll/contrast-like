extends Node3D

@onready 
var camera_system: CompCameraHandler = $"../CameraHandler"
@onready 
var player: CharacterBody3D = $".."
@onready
var model: Node3D = $"../Model"

var wall_tangent : Vector3

@export
var move_speed : float = 100.0
@export
var rotation_speed := PI
var acceleration := 40.0
var cur_speed : float = 0.0

var climbing := false

func _physics_process(delta: float) -> void:
	var move_vector := Input.get_vector(
		&"move_left",
		&"move_right",
		&"move_forward",
		&"move_backward"
	)
	
	if(move_vector.length() < 0.05):
		cur_speed = 0
	elif cur_speed < move_speed:
		cur_speed += acceleration * delta
	
	if Input.is_action_just_pressed(&"ui_accept"):
		if climbing:
			climbing = false
		elif player.is_on_wall():
			climbing = true
	
	if climbing:
		player.velocity = cur_speed * (
			move_vector.x * wall_tangent +
			-move_vector.y * Vector3.UP)
	
	elif player.is_on_floor():
		#mov_dir is the camera system basis * the raw input vector
		# move_vector is the raw input vector
		
		var move_dir := ( 
			move_vector.x * camera_system.basis.x +
		 	move_vector.y * camera_system.basis.z
		)
		var cur_dir := (player.velocity * Vector3(1,0,1)).normalized() #cur_dir is the horizontal direction
		cur_dir = cur_dir.slerp(move_dir,delta * rotation_speed) #spheric interpolation of  mov_dir
		player.velocity = cur_speed * cur_dir + player.velocity * Vector3.UP
		if(move_vector.length() > 0.05):
			model.global_rotation = (atan2(cur_dir.z,cur_dir.x) + PI/2) * Vector3.DOWN
	else:
		player.velocity.y -= 10.0 * delta
	
	
	player.move_and_slide()
