shader_type canvas_item;

uniform vec4 filter_color: source_color;

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	float brightness = (screen_color.r + screen_color.g + screen_color.b) / 3.0;
	vec4 grayscale = vec4(brightness, brightness, brightness, screen_color.a);
	COLOR = grayscale * filter_color;
}
