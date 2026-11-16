extends Node

@export var area: Area3D
@export var target_shape: CollisionShape3D

var _is_triggered := false


func _ready() -> void:
	if area == null:
		area = get_parent() as Area3D
	if target_shape == null:
		return
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not _is_triggered:
		target_shape.set_deferred("disabled", true)
		_is_triggered = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and _is_triggered:
		target_shape.set_deferred("disabled", false)
		_is_triggered = false
