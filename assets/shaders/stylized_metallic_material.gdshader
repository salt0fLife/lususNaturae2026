shader_type spatial;
render_mode diffuse_toon,specular_schlick_ggx;
uniform sampler2D metallic_atlas : source_color, repeat_disable;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 atlas_uv = vec2(1.0) - ((vec2(NORMAL.x,NORMAL.y) + vec2(1.0,1.0))*0.5);
	ALBEDO = vec3(0.0);
	ALBEDO.rg = atlas_uv;
	vec3 m_col = texture(metallic_atlas,atlas_uv).rgb;
	ALBEDO = m_col;
	METALLIC = 1.0;
	ROUGHNESS = 0.5;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
