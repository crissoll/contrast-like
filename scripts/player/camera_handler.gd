class_name CompCameraHandler
extends Node3D

@export
var horizontal_sensitivity := 0.01
@export
var vertical_sensitivity := 0.01

@export_range(0, 90, 0.001, "radians_as_degrees")
var max_pitch : float = PI * 1/4
@export_range(-90,0, 0.001, "radians_as_degrees")
var min_pitch : float = - PI * 1/4

@onready
var pitch_pivot: Node3D = $PitchPivot

@export_group("Inactivity Auto Rotation")
## if you don't touch any camera inputs for "inactivity_time" seconds,
## the camera will automatically align to the rotation of this node
@export 
var inactivity_rotation_target_node : Node3D
@onready
var last_input := Time.get_unix_time_from_system()
## time since last input
@export
var inactivity_time := 1.0
@export_range(0, 6*PI, 0.001, "suffix:rad/s")
var inactivity_rotation_speed := PI/2


@export_group("Portrait Mode")
## radius from last camera input for "portrait mode":
## it allows you to see your character if you don't move too much 
## after using any camera input
@export_range(0,INF,0.1,"suffix:m")
var portrait_mode_radius := 1.0

@onready
var global_pos_at_last_input := global_position
var portrait_mode_radius_passed : bool = false


func is_inactive() -> bool:
	return Time.get_unix_time_from_system() - last_input >= inactivity_time

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if !portrait_mode_radius_passed:
		if global_position.distance_squared_to(global_pos_at_last_input) >\
				portrait_mode_radius ** 2:
			portrait_mode_radius_passed = true
	
	elif is_inactive() and inactivity_rotation_target_node != null:
		if angle_difference(
				inactivity_rotation_target_node.global_rotation.y,
				global_rotation.y
				) < PI/4:
			global_rotation.y = rotate_toward(
			global_rotation.y,
			inactivity_rotation_target_node.global_rotation.y,
			delta * inactivity_rotation_speed
		)
	if Input.is_action_just_pressed(&"ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		last_input = Time.get_unix_time_from_system()
		global_pos_at_last_input = global_position
		portrait_mode_radius_passed = false
		rotate_y(-event.relative.x * horizontal_sensitivity)
		pitch_pivot.rotation.x -= event.relative.y * vertical_sensitivity
		pitch_pivot.rotation.x = clampf(
			pitch_pivot.rotation.x, 
			min_pitch, 
			max_pitch)
