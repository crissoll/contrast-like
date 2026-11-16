class_name InteractiveShadow
extends MeshInstance3D

@export var shadow_collision: CollisionShape3D      # shadow collision shape
@export var light: Light3D
@export_flags_3d_physics var target_mask: int = 2  # floor/walls which receive the shadow
@export var extrusion_direction := Vector3.ZERO
@export_range(0.02, 1.0) var update_time := 0.08
@export var max_ray_length := 1000.0

var _vertices_dict: PackedVector3Array
var projected_shadow_shape := ConvexPolygonShape3D.new()
var _shadow_area: Node3D

var _collidable_shadow : StaticBody3D

var _prev_transform: Transform3D

var _pending := true      # true = primo aggiornamento al primo frame fisico
var _time_left := 0.0


func _ready() -> void:
	_init_shadow_collider()
	_vertices_dict = _unique_vertices_dict()
	_prev_transform = global_transform


func _init_shadow_collider() -> void:
	shadow_collision.shape = projected_shadow_shape
	_shadow_area = shadow_collision.get_parent()   # Area3d


func _unique_vertices_dict() -> PackedVector3Array:
	var seen := {}
	for s in mesh.get_surface_count():
		var verts: PackedVector3Array = mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]
		for v in verts:
			seen[v] = true
	print(seen)
	return PackedVector3Array(seen.keys())


func _physics_process(delta: float) -> void:
	_shadow_area.global_position = global_position

	# ricalcola solo se l'oggetto si è mosso,
	# e al massimo una volta ogni update_time secondi
	if global_transform != _prev_transform and not _pending:
		_pending = true
		_time_left = update_time
	_prev_transform = global_transform

	if _pending: #futura ulteriore ottimizzazione: se il player e' al di sopra di un certo treshold di dstanza, non ricalcolare la poszione dell'ombra (dato che solo il player potra' spostare oggetti per ora)
		_time_left -= delta 
		if _time_left <= 0.0:
			_pending = false
			_update_shadow_collider()


func _update_shadow_collider() -> void:
	projected_shadow_shape.points = _compute_shadow_points()


func _compute_shadow_points() -> PackedVector3Array:
	var n := _vertices_dict.size()
	var projected_points := PackedVector3Array()
	projected_points.resize(n * 2)

	var space := get_world_3d().direct_space_state
	var dir := -light.global_transform.basis.z   # luce direzionale: stessa direzione per tutti

	for i in n:
		var p := global_transform * _vertices_dict[i]   # TransformPoint

		if not (light is DirectionalLight3D):
			dir = (p - light.global_position).normalized()  # luce puntiforme: raggi divergenti

		projected_points[i] = _intersection_point(space, p, dir)
		projected_points[n + i] = _extrusion_point(p, projected_points[i])

	return projected_points

## Intersection points are where the shadow lands. For each vertex of the object, a ray goes out along the light direction, and the point where it hits the ground or a wall is the intersection point. Together these trace the outline of the shadow on the surface, so they’re the bottom of the volume.
func _intersection_point(space: PhysicsDirectSpaceState3D, from: Vector3, dir: Vector3) -> Vector3:
	var to := from + dir * max_ray_length
	var query := PhysicsRayQueryParameters3D.create(from, to, target_mask)
	var hit := space.intersect_ray(query)
	if hit.is_empty():
		return to - global_position        # nessun ostacolo: punto "all'infinito"
	return hit.position - global_position  # coordinate relative all'oggetto

## Extrusion points give that flat outline some thickness. Intersection points alone would make a flat, zero-height shape, which can’t really contain a player. So each intersection point gets a partner point, and what that partner is depends on extrusion_direction
func _extrusion_point(vertex_world: Vector3, shadow_point_rel: Vector3) -> Vector3:
	if extrusion_direction == Vector3.ZERO:
		return vertex_world - global_position  # volume oggetto → ombra
	return shadow_point_rel + extrusion_direction  # lastra sopra l'ombra
