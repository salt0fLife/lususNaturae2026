shader_type spatial;
render_mode unshaded,skip_vertex_transform,cull_front;
uniform sampler2D depth_texture : hint_depth_texture;
uniform sampler3D cloud_texture_1 : repeat_enable;
uniform float density = 0.5;
uniform float cloud_scale = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

uniform int max_steps = 156;
uniform float step_distance = 2.0;

float get_cloud_value(vec3 pos){
	vec3 c = texture(cloud_texture_1,pos*2.0*cloud_scale).xyz;
	return c.x;
}


void fragment() {
	// Called for every pixel the material is visible on.
	float depth = texture(depth_texture, SCREEN_UV).r;
	vec3 camera_pos = CAMERA_POSITION_WORLD;
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec3 dir = normalize(world_pos - CAMERA_POSITION_WORLD);
	int s = 0;
	float val = 0.0;
	ALPHA = 0.0;
	while (s < max_steps){
		s += 1;
		float dis = float(s)*step_distance;
		vec3 step_pos = dir*step_distance*float(s)+camera_pos;
		val = get_cloud_value(step_pos);
		ALPHA += val*density*0.001*val;
		if (dis > depth) {
			break;
		}
	}
	ALBEDO = vec3(1.0,1.0,1.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
