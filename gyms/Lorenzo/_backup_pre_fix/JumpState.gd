extends State

func enter(previous_state_path: String, data := {}) -> void:
	print("jump")
	#future animation
	pass
 
 
func physics_update(delta: float) -> void:
	var dir := player.get_move_direction()
	player.apply_air_movement(dir,player.walk_speed,delta)
	player.apply_gravity(delta)
	player.rotate_visuals_towards(dir, delta)
	player.move_and_slide()
	
	
	check_landing()
	if player.wants_jump() and !player.is_on_floor():
		finished.emit(&"DoubleJumpState", {})
	elif not player.is_on_floor() and player.velocity.y <=0 :
		finished.emit(&"FallState", {})
		
