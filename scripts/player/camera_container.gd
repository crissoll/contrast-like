class_name CameraContainer
extends Node3D

var target : Node3D

@onready
var last_global_position := global_position
var max_distance_passed := false
var max_distance := 0.6
var cur_distance : float
@onready 
var camera: Camera3D = $SpringArm3D/Camera3D

func _ready() -> void:
	camera.current = true
	global_position = target.global_position

func _physics_process(delta: float) -> void:
	if last_global_position == target.global_position:
		cur_distance = max_distance
	last_global_position = target.global_position
	
	var to_target: Vector3 = target.global_position - global_position
	var dist: float = to_target.length()

	if dist > cur_distance:
		global_position = target.global_position - to_target.normalized() * cur_distance

	if cur_distance > 0.0:
		cur_distance = max(0.0, cur_distance - delta)
	
	global_rotation = target.global_rotation
