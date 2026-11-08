class_name State
extends Node

signal finished(next_state: States, data: Dictionary)

enum States {
	NULL,
	IDLE,
	MOVE,
	JUMP,
	FALL,
	DOUBLE_JUMP,
}

var gravity_scale := 1.0
@export_group("")
var overwrite_gravity := false

var player : Player

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass


## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass


## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	pass


## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state: States, data := {}) -> void:
	pass


## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	pass


## Asks the state machine to switch state. The switch happens immediately
## (signals are synchronous), so return right after calling it.
func transition_to(state: States, data := {}) -> void:
	finished.emit(state, data)


## If the player is on the floor, switches to Move or Idle and returns true.
## Usage: `if check_landing(): return`
func check_landing() -> bool:
	if not player.is_on_floor():
		return false
	transition_to(States.MOVE if player.has_move_input() else States.IDLE)
	return true
