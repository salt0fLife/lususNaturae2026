shader_type canvas_item;
uniform sampler2D ScreenTexture : hint_screen_texture;
uniform float spiral = 0.0;
uniform float wave = 0.0;
uniform float flash = 0.0;
uniform vec3 flash_color : source_color;
uniform sampler2D noise_1 : repeat_enable;
uniform sampler2D red_ramp;
uniform sampler2D green_ramp;
uniform sampler2D blue_ramp;
uniform float grading_power;
uniform sampler2D lightness_map;
uniform float lightness_map_power;
uniform float heart_pounding = 0.0;
uniform sampler2D vingette_tex : filter_linear;
uniform vec3 blood_col : source_color;
uniform sampler2D vision_veins :filter_linear;
uniform vec3 fire_color : source_color;
uniform sampler2D fire_noise : filter_linear, repeat_enable;
uniform sampler2D screen_gradient : filter_linear;
uniform bool burning = false;
uniform float action_lines: hint_range(0.0,1.0,0.01) = 0.0;
uniform sampler2D action_lines_noise : repeat_enable;
uniform vec4 line_color: source_color;
uniform float line_count: hint_range(0.0, 2.0, 0.05) = 0.5;
uniform float line_density: hint_range(0.0, 1.0) = 0.5;
uniform float line_faloff: hint_range(0.0, 1.0) = 0.25;
uniform float mask_size: hint_range(0.0, 1.0) = 0.1;
uniform float mask_edge: hint_range(0.0, 1.0) = 0.5;
uniform float animation_speed: hint_range(1.0, 20.0) = 0.5;
uniform bool piss = false;
uniform float shock: hint_range(0.0,1.0) = 0.0;
uniform vec3 shock_col: source_color;
uniform float cinematic: hint_range(0.0,1.0) = 0.0;
uniform vec3 cinematic_col: source_color;
uniform float damaged: hint_range(0.0,1.0) = 0.0;
uniform float color_pop: hint_range(0.0, 1.0, 0.1) = 0.0;
uniform bool impact_frame = false;
uniform vec3 impact_color : source_color;
uniform vec3 impact_color_2 : source_color;
uniform float sharpness_distance = 0.002;
uniform bool sharpen = true;
uniform float sharpness_strength = 0.5;
uniform bool blur_whites = false;
uniform float blur_distance = 0.002;

float inv_lerp(float from, float to, float value){
  return (value - from) / (to - from);
}
vec2 polar_coordinates(vec2 uv, vec2 center, float zoom, float repeat)
{
	vec2 dir = uv - center;
	float radius = length(dir) * 2.0;
	float angle = atan(dir.y, dir.x) * 1.0/(PI * 2.0);
	return mod(vec2(radius * zoom, angle * repeat), 1.0);
}
vec2 rotate_uv(vec2 uv, vec2 pivot, float rotation) {
    float cosa = cos(rotation);
    float sina = sin(rotation);
    uv -= pivot;
    return vec2(
        cosa * uv.x - sina * uv.y,
        cosa * uv.y + sina * uv.x 
    ) + pivot;
}
vec2 spiral_uv(vec2 uv, vec2 center, float angle) {
	uv -= center;
	angle = angle/length(uv);
	
	mat2 rm = mat2(
		vec2(cos(angle), -sin(angle)),
		vec2(sin(angle), cos(angle))
	);
	
	uv = rm * uv;
	uv += center;
	return uv;
}
vec2 wavy_uv(vec2 uv) {
	//vec2 uv = UV;
	uv.x += sin(TIME*2.0+wave+uv.y*20.0)*0.01*wave;
	uv.x += sin(TIME*1.5*2.0+wave+uv.y*25.0)*0.01*wave;
	uv.y += sin(TIME*1.25*2.0+wave+uv.x*22.0)*0.01*wave;
	uv.y += sin(TIME*1.4*2.0+wave+uv.x*18.0)*0.01*wave;
	return uv;
}

vec4 get_blurred_col(sampler2D tex, vec2 uv, float dis) {
	vec4 up = texture(tex, uv+vec2(0.0,dis));
	vec4 down = texture(tex, uv+vec2(0.0,-dis));
	vec4 left = texture(tex, uv+vec2(-dis,0.0));
	vec4 right = texture(tex, uv+vec2(dis,0.0));
	return ((up+down+left+right)*0.25);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = wavy_uv(SCREEN_UV);
	COLOR = texture(ScreenTexture, spiral_uv(uv, vec2(0.5), spiral));
	
	float brightness = (COLOR.r+COLOR.b+COLOR.g)*0.33333;
	
	if (sharpen){
		vec4 blurred = get_blurred_col(ScreenTexture, spiral_uv(uv, vec2(0.5), spiral),sharpness_distance);
		COLOR += (COLOR-blurred)*sharpness_strength;
		}
	
	if (blur_whites) {
		vec4 blurred = get_blurred_col(ScreenTexture, spiral_uv(uv, vec2(0.5), spiral),blur_distance);
		if ((blurred.r + blurred.g + blurred.b)*0.33333 > brightness){
			COLOR -= (COLOR-blurred)*0.5;
		}
		blurred = get_blurred_col(ScreenTexture, spiral_uv(uv, vec2(0.5), spiral),blur_distance*2.0);
		COLOR -= (COLOR-blurred)*brightness*brightness;
	}
	
	
	vec3 col_flash = mix(flash_color - 0.2, flash_color, texture(noise_1, spiral_uv(uv, vec2(0.5), 0.5) + vec2(TIME*0.25)).r);
	COLOR = vec4(mix(COLOR.rgb, flash_color, flash), 1.0);
	COLOR.rgb = mix(COLOR.rgb, col_flash, flash);
	vec3 graded_col = vec3(0.0,0.0,0.0);
	graded_col += texture(red_ramp,vec2(COLOR.r,0.0)).rgb;
	graded_col += texture(blue_ramp,vec2(COLOR.b,0.0)).rgb;
	graded_col += texture(green_ramp,vec2(COLOR.g,0.0)).rgb;
	COLOR.rgb = mix(COLOR.rgb,graded_col,grading_power);
	float luminance = (COLOR.r + COLOR.g + COLOR.b) * 0.33333333333;
	vec3 lum_grad_col = vec3(1.0) * mix(vec3(0.0), texture(lightness_map, vec2(luminance,0.0)).rgb, lightness_map_power);
	COLOR.rgb += lum_grad_col;
	float h_p = heart_pounding*0.5*heart_pounding*1.25 + sin(TIME*6.1+sin(TIME*12.0))*0.025 + damaged;
	vec4 vingette = texture(vingette_tex,UV);
	vec4 veins = texture(vision_veins,UV);
	if (veins.r*vingette.r*h_p > 0.1){
		//COLOR.rgb = mix(COLOR.rgb,blood_col,h_p);
		COLOR.rgb = mix(COLOR.rgb,blood_col,vingette.r*h_p*2.0);
	}
	if (heart_pounding > 0.5) {
		COLOR.rgb = mix(COLOR.rgb,COLOR.rgb+blood_col,(heart_pounding-0.5)*veins.r*0.2);
	}
	vec3 fire = texture(screen_gradient,UV).rgb*(texture(fire_noise,UV*vec2(2.0,2.0)+vec2(TIME*0.5,TIME*1.2))*texture(fire_noise,UV*vec2(2.0,2.0)+vec2(-TIME*0.5,TIME*1.5))).rgb;
	if (burning) {
		if (fire.r > 0.15){
			COLOR.rgb = mix(fire_color,vec3(1.0,1.0,1.0),fire.r);
		}
		if (fire.r > 0.1){
			COLOR.rgb += fire_color;
		}
	}
	
	
	//speed lines
	vec2 polar_uv = polar_coordinates(rotate_uv(UV, vec2(0.5), floor(fract(TIME) * animation_speed*action_lines) ) , vec2(0.5), 0.01, line_count);
	vec3 lines = texture(action_lines_noise, polar_uv).rgb;
	
	float mask_value = length(UV - vec2(0.5));
	float mask = inv_lerp(mask_size, mask_edge, mask_value);
	float result = 1.0 - (mask * line_density*action_lines);
	
	result = smoothstep(result, result + line_faloff, lines.r);
	
	COLOR.rgb = mix(COLOR.rgb, vec3(line_color.rgb), min(line_color.a, result));
	float vingette_simple = (sin(UV.y*PI+PI)+1.0)*0.5 + (sin(UV.x*PI+PI)+1.0)*0.5;
	
	
	COLOR.rgb = mix(COLOR.rgb,blood_col,(damaged*0.5 + vingette_simple*0.5)*damaged);
	COLOR.rgb = mix(COLOR.rgb, brightness+blood_col,damaged);
	
	//COLOR.rgb = mix(COLOR.rgb,COLOR.rgb = mix(COLOR.rgb,blood_col,vingette.r*h_p*2.0),damaged);
	
	
	if (piss) {
		//COLOR.b *= 0.75;
		//float brightness = (COLOR.r+COLOR.b)*0.33333;
		COLOR.rgb = mix(COLOR.rgb,vec3(COLOR.r,COLOR.g,COLOR.b * brightness),0.5);
	}
	
	//shock
	COLOR.rgb = mix(COLOR.rgb,brightness*shock_col*2.0 + COLOR.rgb*0.5 + vingette_simple,shock);
	COLOR.rgb = mix(COLOR.rgb,vec3(COLOR.r,COLOR.g,COLOR.b * brightness),cinematic*0.5);
	COLOR.rgb = mix(COLOR.rgb,brightness*cinematic_col*2.0 + COLOR.rgb*0.5 - vingette_simple,cinematic);
	
	float dif_1 = abs(COLOR.r - COLOR.g);
	float dif_2 = abs(COLOR.g - COLOR.b);
	float dif_3 = abs(COLOR.b - COLOR.r);
	
	//COLOR.rgb = mix(COLOR.rgb, vec3(1.0,1.0,1.0)*brightness, (dif_1+dif_2+dif_3)*0.33333*color_pop);
	if (dif_1 < color_pop && dif_2 < (color_pop) && dif_3 < (color_pop)) {
		COLOR.rgb = mix(COLOR.rgb, vec3(1.0,1.0,1.0)*brightness, 0.3);
	}
	if (impact_frame) {
		float res_2 = (1.0 - (mask * line_density));
		res_2 = smoothstep(res_2, res_2 + line_faloff, lines.r);
		if ((COLOR.r+res_2) > 0.75 || (COLOR.g+res_2) > 0.75 || (COLOR.b+res_2) > 0.75) {
			COLOR.rgb = impact_color;
		}
		else {
		COLOR.rgb = impact_color_2;
		COLOR.rgb -= texture(screen_gradient,UV).rgb*0.5;
		}
		mix(COLOR.rgb, vec3(line_color.rgb), min(line_color.a, result));
	}
	
	
	
	
	//COLOR.a = min(line_color.a, result);
	
	//COLOR.rgb = mix(COLOR.rgb, blood_col,(vingette.r+sin(TIME*10.0+sin(TIME*20.0))*0.1)*heart_pounding*0.5);
	//
	//if ((vingette.r+sin(TIME*10.0+sin(TIME*20.0))*0.01+texture(vision_veins, UV).r*0.25)*heart_pounding > 0.2) {
		////COLOR = texture(ScreenTexture,UV+vec2(vingette.r*heart_pounding*0.001*sin(TIME*4.0),vingette.r*heart_pounding*0.001*sin(TIME*4.0)));
		//COLOR.rgb = mix(COLOR.rgb,blood_col,vingette.r*heart_pounding);
		////COLOR = texture(ScreenTexture,UV+vec2(vingette.r*heart_pounding,vingette.r*heart_pounding));
	//}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
