shader_type spatial;
uniform sampler2D layer_01 : repeat_enable, source_color;
uniform sampler2D layer_02 : repeat_enable, source_color;
uniform sampler2D layer_03 : repeat_enable, source_color, filter_linear;
uniform sampler2D layer_04 : repeat_enable, source_color,filter_linear;
uniform sampler2D noise_texture : repeat_enable,filter_linear;
uniform float depth_scale = 1.0;
uniform float roughness_1 = 0.5;
uniform float roughness_2 = 0.5;
uniform float roughness_3 = 0.5;
uniform float roughness_4 = 0.5;
uniform float metallic = 0.5;
uniform float wobble = 0.0;
uniform float wobble_speed = 1.0;
uniform float wobble_frequency = 1.0;
uniform float texture_movement = 0.0;
uniform float texture_morph = 1.0;
uniform sampler2D metallic_atlas : source_color, repeat_disable;
#include "res://assets/shaders/cloud_shadows.gdshaderinc"


vec2 parallax(float depth, vec3 n, vec3 t, vec3 v) {
	vec3 normal = normalize(n);
	vec3 tangent = normalize(t);
	vec3 bitangent = cross(normal, tangent);
	vec3 view = normalize(v);
	vec3 view_tangent = vec3(dot(view, tangent), dot(view, bitangent), dot(view, normal));
	vec2 offset = (view_tangent.xy / max(view_tangent.z, 0.001)) * depth;
	offset = vec2(-offset.x, offset.y);
	return offset;
}

void vertex() {
	fragment_worldpos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.x += sin(VERTEX.y*10.0*wobble_frequency+TIME*wobble_speed)*wobble*0.01;
	VERTEX.y += sin(VERTEX.x*12.0*wobble_frequency+TIME*wobble_speed+PI*0.25)*wobble*0.01;
	VERTEX.z += sin(VERTEX.y*14.0*wobble_frequency+TIME*wobble_speed+PI*0.7)*wobble*0.01;
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 base_uv = UV;
	vec4 tex_1 = texture(layer_01,base_uv + parallax(depth_scale*0.3,NORMAL,TANGENT,VIEW));
	vec4 tex_2 = texture(layer_02,base_uv + parallax(depth_scale*0.2,NORMAL,TANGENT,VIEW));
	vec4 tex_3 = texture(layer_03,base_uv + parallax(depth_scale*0.1,NORMAL,TANGENT,VIEW));
	vec4 tex_4 = texture(layer_04,base_uv);
	
	vec3 noise_mod = texture(noise_texture,base_uv+vec2(0.0,TIME*texture_movement)).rgb;
	noise_mod *= texture(noise_texture,base_uv+vec2(TIME*0.1*texture_movement*texture_morph,TIME*texture_movement*1.33*texture_morph)).rgb;
	noise_mod = clamp(noise_mod*2.0,0.0,1.0);
	vec3 col = tex_1.rgb;
	col = mix(col,tex_2.rgb,tex_2.a*noise_mod.r);
	col = mix(col,tex_3.rgb,tex_3.a*noise_mod.g);
	col = mix(col,tex_4.rgb,tex_4.a*noise_mod.b);
	ALBEDO = col;
	float r = roughness_1;
	r = mix(r,roughness_2,tex_2.a*noise_mod.r);
	r = mix(r,roughness_3,tex_3.a*noise_mod.g);
	r = mix(r,roughness_4,tex_4.a*noise_mod.b);
	ROUGHNESS = r;
	//EMISSION = tex_4.rgb*tex_4.a*0.1*noise_mod.r+tex_2.rgb*tex_2.a*noise_mod.g*0.1;
	//EMISSION = mix(EMISSION,vec3(0.0,0.0,0.0),tex_2.a*noise_mod.r);
	//EMISSION = mix(EMISSION,vec3(0.0,0.0,0.0),tex_3.a*noise_mod.g);
	//EMISSION = mix(EMISSION,vec3(0.0,0.0,0.0),tex_4.a*noise_mod.b);
	METALLIC = metallic;
	// Called for every pixel the material is visible on.
	vec2 atlas_uv = vec2(1.0) - ((vec2(NORMAL.x,NORMAL.y) + vec2(1.0,1.0))*0.5);
	vec3 m_col = texture(metallic_atlas,atlas_uv).rgb;
	ALBEDO += m_col*vec3(0.5,0.1,0.1);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
