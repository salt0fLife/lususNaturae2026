shader_type spatial;
uniform sampler2D depth_texture : hint_depth_texture;
uniform float prox_fade_distance = 5.0;
uniform sampler2D water_texture : source_color, filter_linear, repeat_enable;
uniform float current_speed = 1.0;
uniform vec2 uv_scale = vec2(1.0,1.0);
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float depth_tex = textureLod(depth_texture,SCREEN_UV,0.0).r;
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV*2.0-1.0,depth_tex,1.0);
	world_pos.xyz/=world_pos.w;
	float v = clamp(smoothstep(world_pos.z+prox_fade_distance,world_pos.z,VERTEX.z),0.0,1.0);
	ALBEDO.r = v;
	vec2 current_uv = UV*uv_scale + vec2(TIME*current_speed,0.0);
	vec3 col = texture(water_texture,current_uv).rgb;
	ALBEDO.gb = col.gb;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
