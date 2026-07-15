// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform vec4 albedo_shadow : source_color;
uniform float roughness : hint_range(0,1);
uniform float specular : hint_range(0,1);
uniform int grass_steps = 3;
uniform float grass_scale = 10.0;
uniform float grass_depth_scale = 1.0;
uniform float depth_offset = 1.0;
uniform float uv_scale = 1.0;
uniform sampler2D heightmap : repeat_enable;
uniform float wind_strength = 1.0;
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

float grass_density(vec2 uv, float power){
	
	//uv.x += sin(uv.y*PI*2.0)*0.1;
	//uv.y += sin(uv.x*PI*2.0)*0.1;
	uv.x+= sin(uv.y*PI*10.0)*0.01;
	uv.y+= sin(uv.x*PI*10.0)*0.01;
	uv.x+= sin(uv.y*PI*5.0)*0.02;
	uv.y+= sin(uv.x*PI*5.0)*0.02;
	
	
	float val = (sin(uv.x*grass_scale)+sin(uv.y*grass_scale))*0.25+0.5;
	float val_2 = (sin(uv.x*grass_scale+PI)+sin(uv.y*grass_scale+PI))*0.25+0.5;
	
	val = (val + (sin(uv.x*grass_scale*0.55)+sin(uv.y*grass_scale*0.51))*0.25+0.5)*0.5;
	val_2 = (val_2 + (sin(uv.x*grass_scale*0.52+PI)+sin(uv.y*grass_scale*0.5+PI))*0.25+0.5)*0.5;
	//
	//val = (val + (sin(uv.x*grass_scale*0.7)+sin(uv.y*grass_scale*0.75))*0.25+0.5)*0.5;
	//val_2 = (val_2 + (sin(uv.x*grass_scale*0.6+PI)+sin(uv.y*grass_scale*0.7+PI))*0.25+0.5)*0.5;
	//
	val *= val;
	val_2 *= val_2;
	
	val = roundEven(val*power*1.2);
	val_2 = roundEven(val_2*power*1.2);
	val = (val+val_2);
	
	
	return val;
}

float heightmap_density(vec2 uv, float power) {
	uv.x+= sin(uv.y*PI*10.0*0.5)*0.01;
	uv.y+= sin(uv.x*PI*11.1*0.5)*0.01;
	uv.x+= sin(uv.y*PI*5.0*0.5)*0.02;
	uv.y+= sin(uv.x*PI*5.2*0.5)*0.02;
	uv.x+= sin(uv.y*PI*0.5)*0.09;
	uv.y+= sin(uv.x*PI*1.1*0.5)*0.09;
	
	uv.x += sin(uv.y*PI*0.1);
	uv.y += sin(uv.x*PI*0.1);
	
	float val = texture(heightmap,uv*4.0).r;
	val = roundEven(val*power);
	return val;
}

void vertex() {
	UV = UV*uv_scale;
}

vec2 wind_offset(vec2 uv) {
	vec2 wind = vec2(0.0,0.0);
	wind.x += sin(TIME*uv.y*10.0*SunshineClouds_WindSpeed*SunshineClouds_WindDirection.x)*0.01;
	wind.y += sin(TIME*uv.x*10.0*SunshineClouds_WindSpeed*SunshineClouds_WindDirection.y)*0.01;
	return wind*wind_strength;
}

void fragment() {
	fragment_worldpos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 base_uv = UV;
	ALBEDO = albedo.rgb;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	ALBEDO = albedo_shadow.rgb;
	for (int i = 0; i < grass_steps; i++) {
		float current_depth = float(i)/float(grass_steps);
		vec2 current_uv = base_uv + wind_offset(base_uv)*current_depth + parallax((1.0-current_depth+depth_offset)*grass_depth_scale,NORMAL, TANGENT,VIEW);
		float gd = heightmap_density(current_uv,1.0-current_depth);
		vec3 current_color = mix(albedo_shadow,albedo,current_depth).rgb;
		ALBEDO = mix(ALBEDO,current_color,gd);
		}
	
}
