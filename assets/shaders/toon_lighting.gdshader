shader_type spatial;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap, repeat_disable;
uniform sampler2D depth_texture: source_color, hint_depth_texture, filter_nearest;
//uniform sampler2D normal_texture: source_color, hint_normal_roughness_texture, filter_nearest;

uniform sampler2D attenuation_steps_texture: repeat_disable;

void vertex() {
	// Called for every vertex the material is visible on.
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 color = texture(screen_texture, SCREEN_UV).rgb;
	//color.g = 0.0;
	//color.b = 0.0;
	ALBEDO = color;
}

void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
	//DIFFUSE_LIGHT += texture(attenuation_steps_texture, vec2(clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION, 0.0)).rgb * LIGHT_COLOR;
}
