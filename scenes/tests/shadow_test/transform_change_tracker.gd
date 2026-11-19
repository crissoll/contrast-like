class_name TransformChangeTracker
extends Node

signal node_transform_changed(node:Node3D)
signal node_tracking_started(node:Node3D)

func add_tracking(target:Node3D) -> void:
	var remote := TransformNotifier.new()
	target.add_child(remote)
	remote.transform_changed.connect(_on_remote_transform_changed)
	node_tracking_started.emit(target)

func _on_remote_transform_changed(node:Node3D) -> void:
	node_transform_changed.emit(node)
