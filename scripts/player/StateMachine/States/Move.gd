class_name MoveState 
extends State

func physics_update(delta: float) -> void:
	var dir := player.get_move_direction()
	var speed : float = player.run_speed if Input.is_action_pressed("sprint") else player.walk_speed

	player.apply_horizontal_movement(dir, speed, delta)
	player.apply_gravity(delta)
	player.rotate_visuals_towards(dir, delta)
	player.move_and_slide()

	if player.try_jump():
		transition.emit(&"JumpState")
	elif not player.is_on_floor():
		transition.emit(&"FallState")
	elif not player.has_move_input() and player.get_horizontal_speed() < 0.1:
		transition.emit(&"IdleState")
