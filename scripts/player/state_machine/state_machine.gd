class_name StateMachine extends Node

## Emitted right after a state transition.
signal state_changed(previous_state: State, new_state: State)

## The initial state of the state machine. If not set, the first child node is used.
@export 
var initial_state: State.States = State.States.IDLE

## The current state of the state machine.
@onready 
var state: State.States = initial_state

@export
var states : Dictionary[State.States,State]

var player: Player

func _ready() -> void:
	player = owner as Player
	# Connect to every state's finished signal to transition to the next state.
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)
		state_node.player = player
	# State machines usually access data from the root node of the scene they're part of: the owner.
	# We wait for the owner to be ready to guarantee all the data and nodes the states may need are available.
	# If the owner is already ready, awaiting the signal would hang forever.
	if not owner.is_node_ready():
		await owner.ready
	states[state].enter(State.States.NULL)


func _unhandled_input(event: InputEvent) -> void:
	states[state].handle_input(event)


func _process(delta: float) -> void:
	states[state].update(delta)


func _physics_process(delta: float) -> void:
	# Timers first, so every state reads up-to-date coyote / jump buffer values
	# regardless of the node order in the tree.
	if player:
		player.update_timers(delta)
	states[state].physics_update(delta)
	
	var dir := player.get_move_direction()
	
	if player.is_grounded():
		player.apply_horizontal_movement(dir,player.walk_speed,delta)
	else:
		player.apply_air_movement(dir, player.walk_speed, delta)
	
	player.apply_gravity(delta,states[state].gravity_scale)
	
	player.rotate_visuals_towards(dir, delta)
	
	player.move_and_slide()


func _transition_to_next_state(target_state: State.States, data: Dictionary = {}) -> void:
	
	var previous_state := state
	state = target_state
	states[state].enter(previous_state, data)
	state_changed.emit(previous_state, state)
