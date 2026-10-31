class_name CompCameraHandler
extends Node3D

@export
var horizontal_rotation_sensitivity := 0.03
@export
var vertical_rotation_sensitivity := 0.01

@export_range(0, 90, 0.001, "radians_as_degrees")
var vertical_rotation_max_value : float = PI * 1/4
@export_range(-90,0, 0.001, "radians_as_degrees")
var vertical_rotation_min_value : float = - PI * 1/4

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(&"ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		rotate_y(event.relative.x * horizontal_rotation_sensitivity)
		
		rotation.x += -event.relative.y * vertical_rotation_sensitivity
		rotation.x = clampf(rotation.x, -vertical_rotation_max_value, -vertical_rotation_min_value)
		rotation.z = 0
