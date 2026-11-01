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
		rotate_y(-event.relative.x * horizontal_sensitivity)
		pitch_pivot.rotation.x -= event.relative.y * vertical_sensitivity
		pitch_pivot.rotation.x = clampf(
			pitch_pivot.rotation.x, 
			min_pitch, 
			max_pitch)
