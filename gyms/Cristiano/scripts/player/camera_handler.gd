class_name CompCameraHandler
extends Node3D

@export
var horizontal_sensitivity := 0.01
@export
var vertical_sensitivity := 0.01

@export_range(0.1,10,0.1)
var mouse_sensitivity := 1.0

@export_range(0, 90, 0.001, "radians_as_degrees")
var max_pitch : float = PI * 1/4
@export_range(-90,0, 0.001, "radians_as_degrees")
var min_pitch : float = - PI * 1/4

@onready
var pitch_pivot: Node3D = $PitchPivot

@export_group("Camera Aligment")
@export 
var camera_allignment_target_node : Node3D

@export_range(0, 10*PI, 0.001, "suffix:rad/s")
var aligment_rotation_speed := PI/2
var aligning_camera := false
@onready
var player: CharacterBody3D = $".."

@export_group("Camera Padding")
@export
var max_camera_distance := 1.0:
	set(value):
		max_camera_distance = value
		camera_container.max_distance = max_camera_distance


@onready
var camera_container : CameraContainer = (func()->CameraContainer:
	var cam_con : CameraContainer = load("uid://c7g5rw3652nl2").instantiate()
	cam_con.target = pitch_pivot
	player.add_sibling.call_deferred(cam_con)
	cam_con.max_distance = max_camera_distance
	return cam_con
	).call()


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(&"camera_align"):
		aligning_camera = true
	if global_rotation.y == camera_allignment_target_node.global_rotation.y:
			aligning_camera = false
	if aligning_camera:
		global_rotation.y = rotate_toward(
			global_rotation.y,
			camera_allignment_target_node.global_rotation.y,
			delta * aligment_rotation_speed
		)
	
	if Input.is_action_just_pressed(&"ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var buttons_input_vector := Input.get_vector(
		&"camera_left",&"camera_right",
		&"camera_up",&"camera_down")
	
	if buttons_input_vector.length() > 0.05:
		aligning_camera = false
		rotate_view(buttons_input_vector * 10)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_view(event.relative * mouse_sensitivity)


func rotate_view(rotation_vector:Vector2) -> void:
	rotate_y(-rotation_vector.x * horizontal_sensitivity)
	pitch_pivot.rotation.x -= rotation_vector.y * vertical_sensitivity
	pitch_pivot.rotation.x = clampf(
		pitch_pivot.rotation.x, 
		min_pitch, 
		max_pitch)

func get_planar_basis():
	return global_basis
