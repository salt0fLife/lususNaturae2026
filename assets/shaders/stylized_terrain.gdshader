shader_type spatial;
uniform sampler2D mapping_texture : repeat_disable, filter_linear;
uniform sampler2D albedo_01 : repeat_enable,filter_linear,source_color;
uniform sampler2D albedo_02 : repeat_enable,filter_linear,source_color;
uniform sampler2D albedo_03 : repeat_enable,filter_linear,source_color;
uniform sampler2D albedo_04 : repeat_enable,filter_linear,source_color;
uniform vec2 base_scale = vec2(1.0,1.0);
uniform vec2 scale_01 = vec2(1.0,1.0);
uniform vec2 scale_02 = vec2(1.0,1.0);
uniform vec2 scale_03 = vec2(1.0,1.0);
uniform vec2 scale_04 = vec2(1.0,1.0);
uniform float dither_scale = 100.0;
uniform float dither_strength = 1.0;
#include "res://assets/shaders/cloud_shadows.gdshaderinc"

//const mat4 dither_matrix = mat4(
  //vec4(0.0625, 0.5625, 0.1875,  0.6875),
  //vec4(0.8125, 0.3125, 0.9375,  0.4375),
  //vec4(0.25, 0.75, 0.125, 0.625),
  //vec4(1.0, 0.5, 0.875,  0.375)
//);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	fragment_worldpos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 base_uv = UV * base_scale;
	vec3 map_col = texture(mapping_texture,UV).rgb;
	float dither = dither_matrix[int(UV.x*base_scale.x*dither_scale) % 4][int(UV.y*base_scale.y*dither_scale) % 4];
	//map_col += vec3(dither,dither,dither);
	
	map_col = roundEven((map_col*(1.0-dither*dither_strength)*4.0))*0.25;
	
	vec3 col = texture(albedo_01,base_uv*scale_01).rgb;
	col = mix(col,texture(albedo_02,base_uv*scale_02).rgb,map_col.r);
	col = mix(col,texture(albedo_03,base_uv*scale_03).rgb,map_col.g);
	col = mix(col,texture(albedo_04,base_uv*scale_04).rgb,map_col.b);
	
	ALBEDO = col;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
