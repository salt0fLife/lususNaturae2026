shader_type spatial;
render_mode unshaded, cull_disabled;
uniform sampler2D heat_map_gradient : source_color, repeat_disable, filter_linear;
uniform float distance_fade_min = 20;
uniform float distance_fade_max = 15;
uniform float displacement_amplitude = 0.05;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX += NORMAL * sin(TIME*10.0 + VERTEX.x*100.0 + VERTEX.z*50.0 +VERTEX.y*200.0)*displacement_amplitude;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(0.0,0.0,0.0);
	float fresnel = dot(NORMAL,VIEW);
	ALBEDO = texture(heat_map_gradient,vec2(fresnel,0.0)).rgb;
	//ALBEDO = albedo;
	{
		float fade_distance = length(VERTEX);
		const vec3 magic = vec3(0.06711056f, 0.00583715f, 52.9829189f);		float fade = clamp(smoothstep(distance_fade_min, distance_fade_max, fade_distance), 0.0, 1.0);
		if (fade < 0.001 || fade < fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
			discard;
		}
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
