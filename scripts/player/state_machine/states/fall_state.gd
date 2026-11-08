extends State
func enter(previous_state_path: String, data := {}) -> void:
	#future animation
	print("fall")
	pass

func _ready() -> void:
	await get_parent().ready
	gravity_scale = player.falling_gravity_multiplier

func physics_update(delta: float) -> void:
	var dir := player.get_move_direction()

	if check_landing():
		return
	# Coyote jump: only works if we walked off a ledge (after a jump the coyote timer is 0).
	if player.try_jump():
		transition_to(JUMP)
	# Air jump: only available after a jump from the ground.
	elif player.wants_jump() and player.can_air_jump():
		transition_to(DOUBLE_JUMP)
