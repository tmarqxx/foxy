shader_type spatial;
//render_mode unshaded;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_toon, specular_toon;

uniform vec4 albedo: source_color;
uniform sampler2D color_gradient: repeat_disable;
uniform sampler2D fresnel_gradient: repeat_disable;
uniform sampler2D rim_gradient: repeat_disable;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow(1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0), amount);
}


void vertex() {
	// Called for every vertex the material is visible on.
}

//void fragment() {
	//ROUGHNESS = 1.0;
	//METALLIC = 0.0;
	//
	//// Called for every pixel the material is visible on.
	////float fresnel = fresnel(4.0, NORMAL, VIEW);
	////ALBEDO = albedo.rgb + (fresnel * texture(fresnel_gradient, vec2(fresnel, 0.0)).rgb);
	//ALBEDO = albedo.rgb;
//}

void light() {
	 //Called for every pixel for every light affecting the material.
	 //Uncomment to replace the default light processing function with this one.
    //DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * clamp(clamp(LIGHT_COLOR, 0, 0.25), 0.25001, ;
	float n_dot_l = dot(NORMAL, LIGHT);
	
	//float sample = clamp(n_dot_l, 0, 1.0);
	//vec4 shade_color = texture(color_gradient, vec2(sample, 0.0));
	//DIFFUSE_LIGHT += clamp(shade_color.rgb * LIGHT_COLOR, 0.0, 1.0);
	
	float shade_sample = (n_dot_l + 1.0) * ATTENUATION;
	vec4 shade_color = texture(color_gradient, vec2(shade_sample, 0.0));
	DIFFUSE_LIGHT += shade_color.rgb * LIGHT_COLOR;
	//DIFFUSE_LIGHT = texture(color_gradient, vec2(clamp(n_dot_l, 0, 1.0), 0.0)).rgb;
	
	//float rim_sample = clamp(dot(VIEW + NORMAL, VIEW + LIGHT) * clamp(dot(NORMAL, LIGHT), 0, 1.0), 0, 1.0) + 0.05;
	//vec4 rim_color = texture(rim_gradient, vec2(rim_sample, 0.0));
	//if (rim_color.r > 0.0) {
		//SPECULAR_LIGHT += LIGHT_COLOR;
	//}
}
