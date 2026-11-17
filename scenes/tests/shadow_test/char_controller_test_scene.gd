extends Node3D

@export var initial_pos: Marker3D

@export_group("Transizione")
@export var transition_time := 0.6
@export var trans_type: Tween.TransitionType = Tween.TRANS_SINE
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT

@export_group("Wall")
@export_flags_3d_physics var wall_mask: int = 4
@export var wall_offset := 0.5
@export var wall_check_distance := 2.0


var player: Player
var is_shadow := false
var last_player_pos: Vector3
var _tween: Tween

var _wall_normal := Vector3.ZERO
var _last_valid_pos: Vector3
var _shadow_height := 0.0


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
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

##sticks player to wall using the normal
func _stick_to_wall() -> void:
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

## finds the wall next to the marker
func _find_wall(from: Vector3, dir: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, from + dir.normalized() * wall_check_distance, wall_mask)
	return get_world_3d().direct_space_state.intersect_ray(query)
#endregion

## player mesh is not visibile, but his shadows are casted
func _set_shadows_only(shadows_only: bool) -> void:
	for i in player.visuals.get_children():
		if i is GeometryInstance3D:
			i.cast_shadow = (
				GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY if shadows_only
				else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			)

## block player during transition
func _set_player_control(enabled: bool) -> void:
	player.velocity = Vector3.ZERO
	player.set_physics_process(enabled)
