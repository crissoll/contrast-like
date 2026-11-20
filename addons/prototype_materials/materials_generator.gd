@icon("res://addons/prototype_materials/icon.svg")
@tool class_name MaterialGenerator extends Node3D

@export_category("Textures")
@export_dir var textures_path: String = "res://addons/prototype_materials/textures/"

@export_category("Material Options")
@export var world_triplanar: bool = true
@export_range(0.0, 150.0, 0.001) var triplanar_sharpness: float = 3.0
@export var texture_filter: BaseMaterial3D.TextureFilter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC

@export_category("Export Options")
@export_dir var export_path: String = "res://addons/prototype_materials/materials/"

@export_tool_button("Export Materials", "Save") var btn_export = _export_materials

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _export_materials() -> void:
	var themes: PackedStringArray = DirAccess.get_directories_at(textures_path)

	# Creating the base material.
	var standard_material: StandardMaterial3D = StandardMaterial3D.new()
	standard_material.uv1_triplanar = true
	standard_material.uv1_world_triplanar = world_triplanar
	standard_material.uv1_triplanar_sharpness = triplanar_sharpness
	standard_material.texture_filter = texture_filter

	if not DirAccess.dir_exists_absolute(export_path):
			DirAccess.make_dir_absolute(export_path)

	var materials_count: int = 0

	for theme_index in themes.size():
		var theme = themes[theme_index]
		var theme_path = textures_path.path_join(theme)
		var materials = DirAccess.get_files_at(theme_path)
		var export_theme_path = export_path.path_join(theme)
		if not DirAccess.dir_exists_absolute(export_theme_path):
			DirAccess.make_dir_absolute(export_theme_path)

		for material_index in materials.size():
			var material = materials[material_index]
			if material.ends_with(".import"):
				continue
			materials_count = materials_count + 1
			var material_path = theme_path.path_join(material)
			standard_material.albedo_texture = load(material_path)
			var material_name = material.replace("texture", "material").split(".")[0]
			ResourceSaver.save(standard_material, export_theme_path.path_join(material_name + ".tres"))
	
	var dialog = AcceptDialog.new()
	dialog.title = "All materials generated."
	dialog.dialog_text = str(materials_count) + " materials generated at: " + export_path
	dialog.ok_button_text = "Ok"

	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered_clamped()

	dialog.confirmed.connect(dialog.queue_free)

	if Engine.is_editor_hint():
		var fs := EditorInterface.get_resource_filesystem()
		fs.scan_sources()
		fs.scan()
	
	print("Prototype Materials: Finish, ", materials_count, " created")

	_update_materials()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if not DirAccess.dir_exists_absolute(export_path + "dark"):
		warnings.append("Export needed, push 'Export Materials' first.")
	
	return warnings

func _update_materials() -> void:
	var meshes = get_children()

	for mesh in meshes:
		var mesh_instance = mesh as MeshInstance3D
		var random_theme = ["dark", "light", "red", "orange", "purple"].pick_random()
		var random_material = randi() % 8 + 1
		var material = export_path.path_join(random_theme).path_join(random_theme + "_material_" + str(random_material) + ".tres")
		mesh_instance.material_override = load(material)