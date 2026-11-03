class_name CameraContainer
extends Node3D

var target : Node3D

var max_distance := 0.6
@onready 
var camera_3d: Camera3D = $SpringArm3D/Camera3D

func _ready() -> void:
	camera_3d.current = true
	global_position = target.global_position

func _physics_process(delta: float) -> void:
	var difference : Vector3 = abs(global_position - target.global_position)
	
	# this is visaully better than a simple distance check, that
	# looks like the character pivots around the center of the camera
	if difference.x > max_distance:
		global_position.x = move_toward(target.global_position.x,global_position.x,max_distance)
	if difference.z > max_distance:
		global_position.z = move_toward(target.global_position.z,global_position.z,max_distance)
	global_rotation = target.global_rotation
