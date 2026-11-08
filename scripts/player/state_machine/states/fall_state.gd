extends State
func enter(_previous_state: States, _data := {}) -> void:
	#future animation
	print("fall")
	pass

func _ready() -> void:
	await get_parent().ready
	gravity_scale = player.falling_gravity_multiplier

func physics_update(_delta: float) -> void:
	if check_landing():
		return
	# Coyote jump: only works if we walked off a ledge (after a jump the coyote timer is 0).
	if player.try_jump():
		transition_to(States.JUMP)
	# Air jump: only available after a jump from the ground.
	elif player.wants_jump() and player.can_air_jump():
		transition_to(States.DOUBLE_JUMP)
