class_name CompShadow
extends Node

#TODO modify this
@onready var initial_pos: Marker3D = $"../../LevelContainer/Marker3D"


@export_group("Transition")
@export var transition_time := 0.6
@export var trans_type: Tween.TransitionType = Tween.TRANS_SINE
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT

@export_group("Wall")
@export_flags_3d_physics var wall_mask: int = Utils.CollisionLayers.WALLS
@export var wall_offset := 0.5
@export var wall_check_distance := 2.0
@export var corner_margin := 0.1

#TODO modify this
@onready var light: SpotLight3D = $"../../LevelContainer/SpotLight3D"

var is_shadow := false
var last_player_pos: Vector3
var _tween: Tween

var _wall_normal := Vector3.ZERO
var _last_valid_pos: Vector3
var _shadow_height := 0.0

@onready var player : Player = get_parent()

func _ready() -> void:
	last_player_pos = player.global_position
	process_physics_priority = player.process_physics_priority + 1


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("shadow_form"):
		return
	if _tween and _tween.is_running():
		return

	if is_shadow:
		_exit_shadow_form()
	else:
		_enter_shadow_form()


func _physics_process(_delta: float) -> void:
	if is_shadow and not (_tween and _tween.is_running()):
		_stick_to_wall()
		
	if player.global_position.length() >= light.global_position.length() + light.spot_range :
		if is_shadow:
			_exit_shadow_form()


#region Transition
func _enter_shadow_form() -> void:
	var wall := _find_wall(initial_pos.global_position, -initial_pos.global_transform.basis.z)
	if wall.is_empty():
		print("no wall found")
		return

	is_shadow = true
	player.set_collision_mask_value(6,true)
	last_player_pos = player.global_position
	_wall_normal = wall.normal
	var target: Vector3 = wall.position + _wall_normal * wall_offset
	_shadow_height = target.y
	_last_valid_pos = target

	_set_shadows_only(true)
	_set_player_control(false)

	_tween = _new_tween()
	_tween.tween_property(player, "global_position", target, transition_time)
	_tween.tween_callback(_set_player_control.bind(true))


func _exit_shadow_form() -> void:
	is_shadow = false
	player.set_collision_mask_value(6,false)
	_set_player_control(false)

	_tween = _new_tween()
	_tween.tween_property(player, "global_position", last_player_pos, transition_time)
	_tween.tween_callback(_set_shadows_only.bind(false))
	_tween.tween_callback(_set_player_control.bind(true))


func _new_tween() -> Tween:
	return create_tween() \
		.set_trans(trans_type) \
		.set_ease(ease_type) \
		.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
#endregion


#region Wall

## sticks player to wall using the normal
func _stick_to_wall() -> void:
	_check_inner_corner()
	var wall := _find_wall(player.global_position, -_wall_normal)

	if wall.is_empty():
		player.global_position = _last_valid_pos
		player.velocity = Vector3.ZERO
		return

	_wall_normal = wall.normal

	var pos: Vector3 = wall.position + _wall_normal * wall_offset
	player.global_position = pos
	player.velocity -= _wall_normal * player.velocity.dot(_wall_normal)
	_last_valid_pos = pos
	
func _check_inner_corner() -> void:
	var input_x := Input.get_axis("move_left", "move_right")
	if is_zero_approx(input_x):
		return

	var wall_right := Vector3.UP.cross(_wall_normal)
	var dir := wall_right * signf(input_x)
	
	_update_wall_normal(dir)
		
## finds the wall where the player will be sticked to
func _find_wall(from: Vector3, dir: Vector3, length := wall_check_distance) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(
		from, from + dir.normalized() * length, wall_mask)
	return player.get_world_3d().direct_space_state.intersect_ray(query)
	
func _get_normal() -> Vector3:
	_check_inner_corner()
	return _wall_normal

func _update_wall_normal(dir : Vector3) -> void:
	var hit := _find_wall(player.global_position, dir, wall_offset + corner_margin)
	if not hit.is_empty():
		_wall_normal = hit.normal
	
#endregion

## player mesh is not visibile, but his shadows are casted
func _set_shadows_only(shadows_only: bool) -> void:
	for i in player.visuals.get_children():
		if i is GeometryInstance3D:
			i.cast_shadow = (
				GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY if shadows_only
				else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			)

## blocks player during transition
func _set_player_control(enabled: bool) -> void:
	player.velocity = Vector3.ZERO
	player.set_physics_process(enabled)
