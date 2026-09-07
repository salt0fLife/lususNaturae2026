// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;
uniform float distance_fade_min;
uniform float distance_fade_max;
uniform float point_size : hint_range(0,128);
uniform vec3 color_base : source_color;
uniform vec3 color_top : source_color;
#include "res://assets/shaders/cloud_shadows.gdshaderinc"
uniform float wind_speed_effect = 1.0;
uniform float wind_strength = 1.0;
uniform vec3 backlight : source_color;

void vertex() {
	fragment_worldpos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float height_falloff = clamp(VERTEX.y,0.0,1.0);
	vec3 global_ver = (VERTEX + NODE_POSITION_WORLD);
	VERTEX.x += sin(TIME*SunshineClouds_WindSpeed*100.0*wind_speed_effect+(global_ver.y+global_ver.z))*0.01*wind_strength*height_falloff;
	VERTEX.y += sin(TIME*SunshineClouds_WindSpeed*100.0*wind_speed_effect*0.77+(global_ver.x+global_ver.z))*0.01*wind_strength*height_falloff;
	VERTEX.z += sin(TIME*SunshineClouds_WindSpeed*100.0*wind_speed_effect+(global_ver.y+global_ver.x))*0.01*wind_strength*height_falloff;
	NORMAL = vec3(0.0,1.0,0.0);
}






void fragment() {
	vec2 base_uv = UV;
	//vec4 albedo_tex = texture(albedo_texture,base_uv);
	//ALPHA = roundEven(albedo_tex.a);
	//ALBEDO = color_base;
	ALBEDO = mix(color_top,color_base,UV.y);
	
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;
	BACKLIGHT = vec3(1.0,1.0,1.0);
	{
		float fade_distance = length(VERTEX);
		const vec3 magic = vec3(0.06711056f, 0.00583715f, 52.9829189f);		float fade = clamp(smoothstep(distance_fade_min, distance_fade_max, fade_distance), 0.0, 1.0);
		if (fade < 0.001 || fade < fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
			discard;
		}
	}

}
