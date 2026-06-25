// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,cull_front,diffuse_burley,specular_disabled,ambient_light_disabled;
uniform vec4 albedo : source_color;
uniform float line_size_change = 0.0;
uniform vec3 center_point_offset = vec3(0.0,0.0,0.0);

void vertex() {
	vec3 dif = ((NODE_POSITION_WORLD+center_point_offset) - CAMERA_POSITION_WORLD);
	float dis = sqrt(sqrt((dif.x * dif.x + dif.z * dif.z) + dif.y * dif.y));
	//VERTEX += NORMAL*0.005*dis;
	VERTEX += NORMAL*dis*(0.01+line_size_change);
}






void fragment() {
	ALBEDO = albedo.rgb;
	BACKLIGHT = ALBEDO*20.0;
	ALBEDO = ALBEDO*0.1;
}
