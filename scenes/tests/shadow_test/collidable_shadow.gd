class_name CollidableShadow
extends MeshInstance3D

@export var shadow_collision: CollisionShape3D      # shadow collision shape
@export var light: Light3D
@export_flags_3d_physics var target_mask: int = 8  # floor/walls which receive the shadow
@export var extrusion_direction := Vector3.ZERO
@export_range(0.02, 1.0) var update_time := 0.08
@export var max_ray_length := 1000.0

var _vertices: PackedVector3Array
var _projected_shadow_shape := ConvexPolygonShape3D.new()
var _shadow_static_body: Node3D

var _prev_transform: Transform3D

var _pending := true
var _time_left := 0.0


func _ready() -> void:
	_init_shadow_collider()
	_vertices = _unique_vertices()
	_prev_transform = global_transform

## assigns the convex polygon shape to the shadow collision shape and assigns the area3d of the shadow to _shadow_area
func _init_shadow_collider() -> void:
	shadow_collision.shape = _projected_shadow_shape
	_shadow_static_body = shadow_collision.get_parent()   # Area3d

## returns the packedVector3Array of all the vertices of the shadow-casting object
func _unique_vertices() -> PackedVector3Array:
	var seen := {}
	for s in mesh.get_surface_count():
		var verts: PackedVector3Array = mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]
		for v in verts:
			seen[v] = true
	print(seen)
	return PackedVector3Array(seen.keys())


func _physics_process(delta: float) -> void:
	_shadow_static_body.global_position = global_position
	
	#calculate only if the object moved, and at most once every update_time seconds
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
	_projected_shadow_shape.points = _compute_shadow_points()

##returns a PackedVector3Array containing:[br]
## - from index 0 to n-1 the vertices of the projected shadow [br]
## - from n to 2n-1 the vertices of the original mesh IF THE EXTRUSION VECTOR DIRECTION IS ZERO, [br]otherwise it returns the projected vertices shifted by the vector direction, obtaining a slab.
func _compute_shadow_points() -> PackedVector3Array:
	var n := _vertices.size()
	var projected_points := PackedVector3Array()
	projected_points.resize(n * 2)

	var space := get_world_3d().direct_space_state
	var dir := -light.global_transform.basis.z   # directional light

	for i in n:
		var p := global_transform * _vertices[i]   #converts vertices of the object from local to global

		if not (light is DirectionalLight3D):
			dir = (p - light.global_position).normalized()  # divergent rays

		projected_points[i] = _intersection_point(space, p, dir)
		projected_points[n + i] = _extrusion_point(p, projected_points[i])

	return projected_points

## Intersection points are where the shadow lands. For each vertex of the object, a ray goes out along the light direction, and the point where it hits the ground or a wall is the intersection point. Together these trace the outline of the shadow on the surface, so they’re the bottom of the volume.
func _intersection_point(space: PhysicsDirectSpaceState3D, from: Vector3, dir: Vector3) -> Vector3:
	var to := from + dir * max_ray_length
	var query := PhysicsRayQueryParameters3D.create(from, to, target_mask)
	var hit := space.intersect_ray(query)
	if hit.is_empty():
		return to - global_position        # no obstacle intersected
	return hit.position - global_position  # local coordinates of the object

## Extrusion points give that flat outline some thickness. Intersection points alone would make a flat, zero-height shape, which can’t really contain a player. So each intersection point gets a partner point, and what that partner is depends on extrusion_direction
func _extrusion_point(vertex_world: Vector3, shadow_point_rel: Vector3) -> Vector3:
	if extrusion_direction == Vector3.ZERO:
		return vertex_world - global_position  
	return shadow_point_rel + extrusion_direction
