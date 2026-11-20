extends Node3D

const COLOR_CYAN := Color(0.12, 0.86, 0.95)
const COLOR_LIME := Color(0.47, 0.95, 0.38)
const COLOR_ORANGE := Color(1.0, 0.58, 0.16)
const COLOR_MAGENTA := Color(0.95, 0.35, 0.82)
const COLOR_YELLOW := Color(1.0, 0.85, 0.25)
const COLOR_WHITE := Color(0.9, 0.94, 1.0)

@onready var player: Player = $Player
@onready var level_container: Node3D = $LevelContainer

var _metrics_label: Label
var _was_grounded := true
var _air_time := 0.0
var _jump_start_height := 0.0
var _jump_peak_height := 0.0
var _jump_peak_speed := 0.0
var _last_air_time := 0.0
var _last_jump_height := 0.0
var _last_jump_peak_speed := 0.0
var _best_air_time := 0.0
var _best_jump_height := 0.0
var _best_horizontal_speed := 0.0
var _completed_jumps := 0


func _ready() -> void:
	_build_environment()
	_build_courses()
	_build_hud()


func _process(delta: float) -> void:
	var grounded := player.is_on_floor()
	var horizontal_speed := player.get_horizontal_speed()
	_best_horizontal_speed = maxf(_best_horizontal_speed, horizontal_speed)

	if _was_grounded and not grounded:
		_air_time = 0.0
		_jump_start_height = player.global_position.y
		_jump_peak_height = 0.0
		_jump_peak_speed = horizontal_speed
	elif not grounded:
		_air_time += delta
		_jump_peak_height = maxf(
			_jump_peak_height,
			player.global_position.y - _jump_start_height
		)
		_jump_peak_speed = maxf(_jump_peak_speed, horizontal_speed)
	elif not _was_grounded and grounded:
		_last_air_time = _air_time
		_last_jump_height = _jump_peak_height
		_last_jump_peak_speed = _jump_peak_speed
		_best_air_time = maxf(_best_air_time, _last_air_time)
		_best_jump_height = maxf(_best_jump_height, _last_jump_height)
		_completed_jumps += 1

	_was_grounded = grounded
	_update_metrics(horizontal_speed, grounded)


func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.035, 0.055, 0.09)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.58, 0.68, 0.82)
	environment.ambient_light_energy = 0.65
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	level_container.add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52.0, -28.0, 0.0)
	sun.light_energy = 1.4
	sun.shadow_enabled = true
	level_container.add_child(sun)

	_add_platform(
		"Gym floor",
		Vector3(0.0, -0.5, -5.0),
		Vector3(90.0, 1.0, 90.0),
		Color(0.12, 0.16, 0.22)
	)

func _build_courses() -> void:
	_add_station(
		"01  VELOCITA' E FRENATA",
		"Corri dritto e rilascia il movimento.\nConfronta velocita' attuale e picco.",
		Vector3(0.0, 3.6, 8.0),
		COLOR_CYAN
	)
	for z in [0.0, -5.0, -10.0, -15.0]:
		_add_marker(Vector3(0.0, 0.035, z), Vector3(5.0, 0.07, 0.14), COLOR_CYAN)
	_add_platform(
		"Speed lane left rail",
		Vector3(-2.8, 0.35, -5.0),
		Vector3(0.18, 0.7, 22.0),
		COLOR_CYAN.darkened(0.55)
	)
	_add_platform(
		"Speed lane right rail",
		Vector3(2.8, 0.35, -5.0),
		Vector3(0.18, 0.7, 22.0),
		COLOR_CYAN.darkened(0.55)
	)

	_add_station(
		"02  SALTO E DISLIVELLO",
		"Percorri i gradini senza fermarti.\nMisura il picco di altezza del salto.",
		Vector3(12.0, 3.6, 8.0),
		COLOR_LIME
	)
	_add_platform("Step 1", Vector3(12.0, 0.15, 1.0), Vector3(3.0, 0.3, 3.0), COLOR_LIME)
	_add_platform("Step 2", Vector3(12.0, 0.5, -2.2), Vector3(2.8, 0.6, 2.6), COLOR_LIME)
	_add_platform("Step 3", Vector3(12.0, 0.85, -5.2), Vector3(2.6, 0.7, 2.6), COLOR_LIME)
	_add_platform("Step 4", Vector3(12.0, 1.2, -8.2), Vector3(2.4, 0.8, 2.6), COLOR_LIME)
	_add_platform("Step 5", Vector3(12.0, 1.55, -11.2), Vector3(2.4, 0.9, 2.6), COLOR_LIME)

	_add_station(
		"03  GAP E DOPPIO SALTO",
		"Prendi la rincorsa e salta il vuoto.\nPremi SPACE di nuovo in aria.",
		Vector3(-12.0, 3.6, 8.0),
		COLOR_ORANGE
	)
	_add_platform(
		"Gap takeoff",
		Vector3(-12.0, 0.25, 1.0),
		Vector3(4.5, 0.5, 10.0),
		COLOR_ORANGE
	)
	_add_platform(
		"Gap landing",
		Vector3(-12.0, 0.25, -8.2),
		Vector3(3.4, 0.5, 3.2),
		COLOR_ORANGE
	)
	_add_platform(
		"Gap follow-up",
		Vector3(-12.0, 0.6, -12.0),
		Vector3(2.8, 0.7, 2.8),
		COLOR_ORANGE
	)

	_add_station(
		"04  CONTROLLO AEREO",
		"Sposta la direzione mentre sei in aria.\nAtterra sulle piattaforme sfalsate.",
		Vector3(-24.0, 3.6, 8.0),
		COLOR_MAGENTA
	)
	_add_platform(
		"Air control launch",
		Vector3(-24.0, 0.25, 1.0),
		Vector3(5.0, 0.5, 7.0),
		COLOR_MAGENTA
	)
	_add_platform(
		"Air control target 1",
		Vector3(-22.0, 0.25, -4.5),
		Vector3(2.4, 0.5, 2.4),
		COLOR_MAGENTA
	)
	_add_platform(
		"Air control target 2",
		Vector3(-18.5, 0.25, -8.0),
		Vector3(2.4, 0.5, 2.4),
		COLOR_MAGENTA
	)
	_add_platform(
		"Air control target 3",
		Vector3(-22.0, 0.25, -11.5),
		Vector3(2.4, 0.5, 2.4),
		COLOR_MAGENTA
	)

	_add_station(
		"05  ATTERRAGGIO DI PRECISIONE",
		"Salta da un bersaglio all'altro.\nConta i salti completati e riduci gli errori.",
		Vector3(24.0, 3.6, 8.0),
		COLOR_YELLOW
	)
	_add_platform(
		"Precision launch",
		Vector3(24.0, 0.25, 1.0),
		Vector3(4.0, 0.5, 5.0),
		COLOR_YELLOW
	)
	_add_platform(
		"Precision target 1",
		Vector3(24.0, 0.25, -4.0),
		Vector3(1.8, 0.5, 1.8),
		COLOR_YELLOW
	)
	_add_platform(
		"Precision target 2",
		Vector3(26.5, 0.45, -7.5),
		Vector3(1.6, 0.9, 1.6),
		COLOR_YELLOW
	)
	_add_platform(
		"Precision target 3",
		Vector3(23.0, 0.25, -11.0),
		Vector3(1.5, 0.5, 1.5),
		COLOR_YELLOW
	)

	_add_station(
		"06  CAMBIO DIREZIONE",
		"Alterna destra e sinistra in corsa.\nOsserva quanto rapidamente cambia la velocita'.",
		Vector3(0.0, 3.6, -20.0),
		COLOR_WHITE
	)
	_add_marker(Vector3(0.0, 0.04, -24.0), Vector3(8.0, 0.08, 0.16), COLOR_WHITE)
	_add_marker(Vector3(0.0, 0.04, -29.0), Vector3(8.0, 0.08, 0.16), COLOR_WHITE)
	_add_marker(Vector3(0.0, 0.04, -34.0), Vector3(8.0, 0.08, 0.16), COLOR_WHITE)

	_add_platform(
		"Turn course block 1",
		Vector3(-2.0, 0.6, -25.0),
		Vector3(1.6, 1.2, 1.6),
		COLOR_WHITE
	)
	_add_platform(
		"Turn course block 2",
		Vector3(2.0, 1.0, -29.0),
		Vector3(1.6, 2.0, 1.6),
		COLOR_WHITE
	)
	_add_platform(
		"Turn course block 3",
		Vector3(-2.0, 0.8, -33.0),
		Vector3(1.6, 1.6, 1.6),
		COLOR_WHITE
	)

	_add_station(
		"07  COYOTE TIME / JUMP BUFFER",
		"Salta subito dopo il bordo; poi prova a saltare\nun istante prima di atterrare.",
		Vector3(36.0, 3.6, 8.0),
		COLOR_CYAN
	)
	_add_platform(
		"Coyote and buffer takeoff",
		Vector3(36.0, 0.25, 1.0),
		Vector3(5.0, 0.5, 10.0),
		COLOR_CYAN
	)
	_add_platform(
		"Coyote and buffer landing",
		Vector3(36.0, 0.25, -8.0),
		Vector3(3.0, 0.5, 3.0),
		COLOR_CYAN
	)
	_add_platform(
		"Coyote and buffer step",
		Vector3(39.0, 0.55, -12.0),
		Vector3(2.4, 1.1, 2.4),
		COLOR_CYAN
	)


func _add_platform(
	block_name: String,
	center: Vector3,
	block_size: Vector3,
	color: Color
) -> void:
	var body := StaticBody3D.new()
	body.name = block_name
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 0
	level_container.add_child(body)

	var shape := BoxShape3D.new()
	shape.size = block_size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)

	var mesh := BoxMesh.new()
	mesh.size = block_size
	mesh.material = _make_material(color)
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	body.add_child(visual)


func _add_marker(center: Vector3, marker_size: Vector3, color: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = marker_size
	mesh.material = _make_material(color)
	var marker := MeshInstance3D.new()
	marker.position = center
	marker.mesh = mesh
	level_container.add_child(marker)


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.72
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.12
	return material


func _add_station(title: String, description: String, position: Vector3, color: Color) -> void:
	var label := Label3D.new()
	label.text = title + "\n" + description
	label.position = position
	label.font_size = 36
	label.pixel_size = 0.01
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.modulate = color
	label.outline_size = 8
	label.outline_modulate = Color(0.015, 0.025, 0.045, 1.0)
	level_container.add_child(label)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)

	var instructions_panel := _create_panel(layer, Vector2(16.0, 16.0), Vector2(440.0, 0.0))
	var instructions := instructions_panel.get_child(0) as VBoxContainer
	_add_hud_line(instructions, "PLAYER MOVEMENT GYM", COLOR_WHITE, 24)
	_add_hud_line(instructions, "WASD: movimento   |   Mouse: telecamera   |   SPACE: salta", COLOR_WHITE, 16)
	_add_hud_line(instructions, "ESC: libera o cattura il mouse", COLOR_WHITE, 16)
	_add_hud_line(instructions, "01  VELOCITA' / FRENATA", COLOR_CYAN, 17)
	_add_hud_line(instructions, "Attraversa i marker; osserva velocita' corrente e massima.", COLOR_WHITE, 14)
	_add_hud_line(instructions, "02  SALTO / DISLIVELLO", COLOR_LIME, 17)
	_add_hud_line(instructions, "Sali i gradini; il picco misura l'altezza del salto.", COLOR_WHITE, 14)
	_add_hud_line(instructions, "03  GAP / DOPPIO SALTO", COLOR_ORANGE, 17)
	_add_hud_line(instructions, "Salta il vuoto; premi SPACE una seconda volta in aria.", COLOR_WHITE, 14)
	_add_hud_line(instructions, "04  CONTROLLO AEREO", COLOR_MAGENTA, 17)
	_add_hud_line(instructions, "Correggi la direzione a mezz'aria e centra le piattaforme.", COLOR_WHITE, 14)
	_add_hud_line(instructions, "05  ATTERRAGGIO / 06  DIREZIONE", COLOR_YELLOW, 17)
	_add_hud_line(instructions, "Prova i bersagli stretti e i cambi di direzione tra i blocchi.", COLOR_WHITE, 14)
	_add_hud_line(instructions, "07  COYOTE / BUFFER / SALTO VARIABILE", COLOR_CYAN, 17)
	_add_hud_line(instructions, "Premi SPACE appena uscito dal bordo o poco prima di toccare terra; rilascia SPACE in salita per accorciare il salto.", COLOR_WHITE, 14)
	_add_hud_line(instructions, "Suggerimento: confronta i valori dopo ogni prova.", COLOR_WHITE, 14)
	instructions_panel.reset_size()

	var metrics_panel := _create_panel(layer, Vector2.ZERO, Vector2(340.0, 0.0))
	_metrics_label = Label.new()
	_metrics_label.add_theme_font_size_override("font_size", 17)
	_metrics_label.add_theme_color_override("font_color", COLOR_WHITE)
	_metrics_label.custom_minimum_size = Vector2(320.0, 0.0)
	_metrics_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_metrics_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_metrics_label.text = "METRICHE LIVE"
	metrics_panel.add_child(_metrics_label)
	var metrics_size := metrics_panel.get_combined_minimum_size()
	metrics_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	metrics_panel.offset_left = -metrics_size.x - 16.0
	metrics_panel.offset_right = -16.0
	metrics_panel.offset_top = 16.0
	metrics_panel.offset_bottom = metrics_size.y + 16.0
	metrics_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _create_panel(layer: CanvasLayer, position: Vector2, minimum_size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = position
	panel.custom_minimum_size = minimum_size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.015, 0.025, 0.045, 0.88)
	style.border_color = Color(0.28, 0.36, 0.48, 0.9)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12.0
	style.content_margin_top = 10.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 10.0
	panel.add_theme_stylebox_override("panel", style)
	layer.add_child(panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(column)
	return panel


func _add_hud_line(parent: VBoxContainer, text: String, color: Color, font_size: int) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.custom_minimum_size = Vector2(405.0, 0.0)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)


func _update_metrics(horizontal_speed: float, grounded: bool) -> void:
	if _metrics_label == null:
		return

	var state_text := "TERRA" if grounded else "ARIA"
	if player.comp_shadow.is_shadow:
		state_text = "OMBRA"

	var height_value := _jump_peak_height if not grounded else _last_jump_height
	var airtime_value := _air_time if not grounded else _last_air_time
	var jump_speed_value := _jump_peak_speed if not grounded else _last_jump_peak_speed
	_metrics_label.text = (
		"METRICHE LIVE\n"
		+ ("Stato: %s\n" % state_text)
		+ ("Velocita' orizzontale: %.2f m/s\n" % horizontal_speed)
		+ ("Picco velocita': %.2f m/s\n" % _best_horizontal_speed)
		+ ("Velocita' verticale: %.2f m/s\n" % player.velocity.y)
		+ ("Altezza ultimo salto: %.2f m\n" % height_value)
		+ ("Tempo in aria: %.2f s\n" % airtime_value)
		+ ("Picco velocita' in aria: %.2f m/s\n" % jump_speed_value)
		+ ("Record salto / aria: %.2f m / %.2f s\n" % [_best_jump_height, _best_air_time])
		+ ("Coyote / buffer: %.2f / %.2f s\n" % [player.coyote_time, player.jump_buffer_time])
		+ ("Salti aerei disponibili: %d\n" % player.max_air_jumps)
		+ ("Atterraggi completati: %d" % _completed_jumps)
	)
