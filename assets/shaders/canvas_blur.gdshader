shader_type canvas_item;
uniform sampler2D ScreenTexture : hint_screen_texture;

vec4 get_blurred_col(sampler2D tex, vec2 uv, float dis) {
	vec4 up = texture(tex, uv+vec2(0.0,dis));
	vec4 down = texture(tex, uv+vec2(0.0,-dis));
	vec4 left = texture(tex, uv+vec2(-dis,0.0));
	vec4 right = texture(tex, uv+vec2(dis,0.0));
	
	vec4 ur = texture(tex, uv+vec2(dis,dis));
	vec4 dr = texture(tex, uv+vec2(dis,-dis));
	vec4 dl = texture(tex, uv+vec2(-dis,-dis));
	vec4 ul = texture(tex, uv+vec2(-dis,dis));
	
	
	return ((up+down+left+right+ur+dr+dl+ul)*0.125);
}

void fragment() {
	vec4 col = get_blurred_col(ScreenTexture,SCREEN_UV,0.0035);
	COLOR = col;
	// Called for every pixel the material is visible on.
}

