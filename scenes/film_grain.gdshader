shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float grain_strength = 0.05;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec3 color = texture(screen_texture, SCREEN_UV).rgb;
    float noise = random(SCREEN_UV + fract(TIME)) - 0.5;
    COLOR = vec4(color + noise * grain_strength, 1.0);
}