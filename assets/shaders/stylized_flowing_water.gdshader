shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_lambert,specular_schlick_ggx;
uniform sampler2D depth_texture : hint_depth_texture;
uniform float prox_fade_distance = 5.0;
uniform float current_speed = 1.0;
uniform vec2 uv_scale = vec2(1.0,1.0);
uniform sampler2D foam_texture : repeat_enable, filter_linear;
uniform vec4 water_color : source_color;
uniform vec4 water_color_2 : source_color;
uniform vec4 foam_color : source_color;
uniform float foam_mult = 1.0;
uniform float edges_mult = 1.0;
uniform float deep_fade_distance;
uniform sampler2D normal_tex;
uniform float normal_speed = 1.0;
uniform vec2 normal_uv_scale = vec2(1.0,1.0);
uniform float foam_desync_speed = 0.0;
uniform sampler2D foam_normal_texture : repeat_enable, filter_linear;
#include "res://assets/shaders/cloud_shadows.gdshaderinc"

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	fragment_worldpos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float depth_tex = textureLod(depth_texture,SCREEN_UV,0.0).r;
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV*2.0-1.0,depth_tex,1.0);
	world_pos.xyz/=world_pos.w;
	float v = clamp(smoothstep(world_pos.z+prox_fade_distance,world_pos.z,VERTEX.z),0.0,1.0);
	//ALBEDO.r = v;
	vec2 current_uv = (UV + vec2(TIME*current_speed,0.0))* uv_scale;
	vec3 col = water_color.rgb;
	
	float deep = 1.0 - clamp(smoothstep(world_pos.z+deep_fade_distance,world_pos.z,VERTEX.z),0.0,1.0);;
	col = mix(col,water_color_2.rgb,deep);
	
	
	
	
	float foam = texture(foam_texture,current_uv).r;
	foam = (foam + texture(foam_texture, current_uv*0.33-vec2(TIME*foam_desync_speed,0.0)).g)*0.33;
	foam += v;
	float edges = 0.5 - sin(UV.y*PI)*0.5;
	foam += edges * edges_mult;
	
	foam *= foam_mult;
	
	foam = clamp(roundEven(foam),0.0,1.0);
	
	col = mix(col,foam_color.rgb,foam);
	
	//normal time
	vec2 normal_uv = (UV + vec2(TIME*0.5*normal_speed,0.0))*normal_uv_scale;
	vec3 norm = texture(normal_tex,normal_uv).rgb;
	norm += texture(normal_tex,normal_uv*2.0+vec2(TIME*0.2,0.0)).rgb;
	norm *= 0.5;
	norm = mix(norm,texture(foam_normal_texture,current_uv).rgb*0.7,foam);
	NORMAL_MAP = norm;
	NORMAL_MAP_DEPTH = 1.0;
	
	
	ROUGHNESS = mix(0.25,0.8,foam);
	ALPHA = 1.0;
	
	
	ALBEDO.rgb = col.rgb*0.333;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
