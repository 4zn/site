shader_type canvas_item;

uniform int steps : hint_range(2, 8) = 3;

void fragment() {
	vec4 col = texture(TEXTURE, UV) * COLOR;
	float a = col.a;
	vec3 c = col.rgb;
	c = floor(c * float(steps)) / float(steps);
	COLOR = vec4(c, a);
}