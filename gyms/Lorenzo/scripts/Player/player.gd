class_name Player
extends CharacterBody3D

#region References
@export_group("References")
@export var camera_rig: CompCameraHandler
#@export var camera_target: Node3D
@export var visuals: Node3D
@export var animation_tree: AnimationTree
#endregion 



#region Movement
@export_group("Movement")
@export var walk_speed := 3.0
@export var run_speed := 6.0 #not used for now
@export var acceleration := 20.0
@export var deceleration := 25.0
@export var air_acceleration := 8.0
@export var air_deceleration := 10.0
@export var rotation_speed := 12.0
@export var visuals_rotation_offset := 0.0
#endregion 


#region Jump And Gravity
@export_group("Jump And Gravity")
@export var jump_velocity := 6.0
@export var overall_gravity_scale := 1.5
@export var jump_interrupted_gravity_multiplier := 2.2
@export var max_fall_speed := 40.0
@export var falling_gravity_multiplier := 1.7
@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12
@export var max_air_jumps := 1
@export var strength_double_jump : float = 1.8

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _air_jumps_left := 0
var _jump_started := false
#endregion 


#region Lifecycle

func update_timers(delta: float) -> void:
	# _jump_started only checks the first frame after having pressed space, after it becomes false since we are not on floor
	if _jump_started and not is_on_floor():
		_jump_started = false

	if is_grounded(): #checks wether we are on the ground AND we didn't start jumping. if we actually jump _coyote_timer = 0
		_coyote_timer = coyote_time
		_air_jumps_left = 0 #you cannot double jump from ground
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0) #when we start falling we decrease the timer of delta each frame

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)

#endregion


#region Inputs
func get_input_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward")


func get_move_direction() -> Vector3:
	var input := get_input_vector()
	if input == Vector2.ZERO:
		return Vector3.ZERO

	var basis_ref := Basis.IDENTITY
	if camera_rig:
		basis_ref = camera_rig.get_planar_basis()

	var dir := basis_ref * Vector3(input.x, 0.0, input.y)
	dir.y = 0.0
	return dir.normalized()


func has_move_input() -> bool:
	return get_input_vector() != Vector2.ZERO


func wants_jump() -> bool:
	return _jump_buffer_timer > 0.0
	
func is_jump_held() -> bool:
	return Input.is_action_pressed("jump")

#endregion 


#region Horizontal Movement

func get_horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()


func apply_horizontal_movement(
		direction: Vector3,
		speed: float,
		delta: float,
		accel := -1.0,
		decel := -1.0) -> void:
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


#region Jump And Gravity
## Always applied, also on the floor: the small downward push keeps the body glued
## to slopes and steps, and move_and_slide() cancels it when there is ground below.
func apply_gravity(delta: float, multiplier := 1.0) -> void:
	velocity.y -= gravity * overall_gravity_scale * multiplier * delta
	velocity.y = maxf(velocity.y, -max_fall_speed)


## On the floor and not in the frame right after a jump.
func is_grounded() -> bool:
	return is_on_floor() and not _jump_started


func can_jump() -> bool:
	return is_grounded() or _coyote_timer > 0.0


## Jump from the ground (or coyote time). Recharges the air jumps.
func try_jump() -> bool:
	if wants_jump() and can_jump():
		jump()
		_air_jumps_left = max_air_jumps
		return true
	return false


func can_air_jump() -> bool:
	return _air_jumps_left > 0


func air_jump(strength_multiplier := 1.0) -> void:
	_air_jumps_left = maxi(_air_jumps_left - 1, 0)
	jump(strength_multiplier)


func jump(strength_multiplier := 1.0) -> void:
	velocity.y = jump_velocity * strength_multiplier
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_jump_started = true
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
