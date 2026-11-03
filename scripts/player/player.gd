extends CharacterBody3D
class_name Player

@export_subgroup("References")
@export var camera_target: Node3D
@export var visuals: Node3D
@export var animation_tree: AnimationTree

@export_group("Stats")
@export_subgroup("Movements")
@export var walk_speed := 100.0
@export var run_speed := 150
@export var max_speed := 100.0
@export var acceleration := 40.0
@export var deceleration := 20.0
@export var air_acceleration := 25.0
@export var air_deceleration := 15.0
@export var rotation_speed := 12.0
@export var visuals_rotation_offset := 0.0

@export_subgroup("Jump")
@export var max_jump_height := 2.0
@export var jump_velocity := 2.0
@export var max_fall_speed := 2.0
@export var gravity_scale := 5.0
@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12

var camera_handler: Node3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
	

func _physics_process(delta: float) -> void:
	_update_timers(delta)
 
 
func _update_timers(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)
 
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)
		
		
	
	
#region INPUTS

func get_input_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
func get_move_direction() -> Vector3:
	var input = get_input_vector()
	var cam_basis : Basis = camera_handler.get_planar_basis()
	return (cam_basis * Vector3(input.x, 0, input.y)).normalized()
	
func has_move_input() -> bool:
	return get_input_vector() != Vector2.ZERO
 
 
func wants_jump() -> bool:
	return _jump_buffer_timer > 0.0
	
#endregion



#region Horizontal Movement

func get_horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()
	

func apply_horizontal_movement(direction: Vector3, speed: float, delta: float, accel := -1.0, decel := -1.0) -> void:
	if accel < 0.0:
		accel = acceleration
	if decel < 0.0:
		decel = deceleration
 
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	var target := direction * speed
	var rate := accel if direction != Vector3.ZERO else decel
	horizontal = horizontal.move_toward(target, rate * delta)
 
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	
func apply_air_movement(direction: Vector3, speed: float, delta: float) -> void:
	apply_horizontal_movement(direction, speed, delta, air_acceleration, air_deceleration)

func stop_horizontal() -> void:
	velocity.x = 0.0
	velocity.z = 0.0

#endregion


#region Vertical Movement
func apply_gravity(delta: float, multiplier := 1.0) -> void:
	if is_on_floor():
		return
	velocity.y -= gravity * gravity_scale * multiplier * delta
	velocity.y = maxf(velocity.y, -max_fall_speed)

func can_jump() -> bool:
	return is_on_floor() or _coyote_timer > 0.0
	
func try_jump() -> bool:
	if wants_jump() and can_jump():
		jump()
		return true
	return false
	
func jump(strength_multiplier := 1.0) -> void:
	velocity.y = jump_velocity * strength_multiplier
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
#endregion


#region Model Rotation
func rotate_visuals_towards(direction: Vector3, delta: float, speed := -1.0) -> void:
	if visuals == null:
		return
	direction.y = 0.0
	if direction.length_squared() < 0.0001:
		return
	if speed < 0.0:
		speed = rotation_speed
 
	var target_angle := atan2(direction.x, direction.z) + visuals_rotation_offset
	var weight := 1.0 - exp(-speed * delta)
	visuals.rotation.y = lerp_angle(visuals.rotation.y, target_angle, weight)
 
 
func snap_visuals_to(direction: Vector3) -> void:
	if visuals == null:
		return
	direction.y = 0.0
	if direction.length_squared() < 0.0001:
		return
	visuals.rotation.y = atan2(direction.x, direction.z) + visuals_rotation_offset
	
#endregion

#region Animations

func set_anim_param(param: StringName, value: Variant) -> void:
	if animation_tree:
		animation_tree.set("parameters/%s" % param, value)
 
 
func travel_anim(state_name: StringName, playback_path := "parameters/playback") -> void:
	if animation_tree == null:
		return
	var playback = animation_tree.get(playback_path)
	if playback is AnimationNodeStateMachinePlayback:
		playback.travel(state_name)
		
#endregion
