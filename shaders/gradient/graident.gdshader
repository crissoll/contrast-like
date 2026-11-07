shader_type spatial;
render_mode diffuse_toon;

uniform sampler2D textura;

uniform vec3 color_arriba: source_color = vec3(0.0, 1.0, 0.0);
uniform vec3 color_abajo: source_color = vec3(1.0, 0.0, 0.0);
// Altura mínima (relativa al modelo, 0 es la base) desde la que empieza el degradado
uniform float altura_minima = 0.0;
// Altura maxima (relativa al modelo, 0 es la base) termina el degradado
uniform float altura_maxima = 6.0;

varying vec3 world_pos;

void vertex() {
	// Posición en el mundo del fragmento para el fragment
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Color de la sombra, degradado desde altura_maxima a altura mínima
	float altura = world_pos.y - NODE_POSITION_WORLD.y;
	float altura_normalizada = clamp((altura - altura_minima) / (altura_maxima - altura_minima), 0.0, 1.0);
	vec3 color_degradado = mix(color_abajo, color_arriba, altura_normalizada);

	// Color de la textura
	vec3 color = texture(textura, UV).rgb;

	// Hacemos un multiply:
	ALBEDO = color * color_degradado;
}
