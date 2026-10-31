class_name CompCameraHandler
extends Node3D

@export
var rotation_sensitivity := Vector2(0.3,0.1)

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
		# Change rotate_y to rotate_object_local to keep Y tracking internal
		rotate_object_local(Vector3.UP, event.relative.x * rotation_sensitivity.x)

		# Change transform.basis.x to Vector3.RIGHT to keep X tracking pure
		rotate_object_local(Vector3.RIGHT, -event.relative.y * rotation_sensitivity.y)

		# NOW this line works perfectly because the math prior didn't corrupt the axes
		rotation.x = clampf(rotation.x, -vertical_rotation_max_value, -vertical_rotation_min_value)
		rotation.z = 0
		
