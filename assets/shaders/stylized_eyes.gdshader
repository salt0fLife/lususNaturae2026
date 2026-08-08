// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,diffuse_burley,specular_schlick_ggx;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec2 eyeSize;
uniform vec2 pupilSize;
uniform vec2 eyePos = vec2(0.0,0.0);
uniform vec3 whitesColor : source_color;
uniform vec3 eyeColor : source_color;
uniform vec3 eyeColor2 : source_color;
uniform vec3 pupilColor : source_color;
uniform float ec2os;
uniform vec2 eyeLids = vec2(0.5,0.5);
uniform float eyeScale = 1.0;
uniform float eyeTaper = 0.0;
uniform vec2 highlightSize;
uniform vec2 highlightPos;
uniform float highlightTrackIntensity = 0.75;
uniform vec2 eyelashes;
uniform vec3 eyelashCol : source_color;
uniform float eyelashTaper;
uniform float transparency = 0.0;
uniform vec3 glow_col : source_color;
uniform vec3 glow_col_2 : source_color;
uniform vec3 glow_col_3 : source_color;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}






void fragment() {
	vec2 uv = UV;
	vec3 color = whitesColor;
	vec3 glow = glow_col*0.01;//vec3(0.0,0.0,0.0);
	//eyeColor
	if (uv.x > eyePos.x - eyeSize.x*0.5*eyeScale && uv.x < eyePos.x + eyeSize.x*0.5*eyeScale && uv.y > eyePos.y - eyeSize.y*0.5*eyeScale && uv.y < eyePos.y + eyeSize.y * 0.5*eyeScale){
		color = eyeColor;
		glow = glow_col_3;
	}
	if (uv.x > eyePos.x - pupilSize.x*0.5*eyeScale-ec2os && uv.x < eyePos.x + pupilSize.x*0.5*eyeScale+ec2os && uv.y > eyePos.y - pupilSize.y*0.5*eyeScale-ec2os && uv.y < eyePos.y + pupilSize.y * 0.5*eyeScale+ec2os){
		color = eyeColor2;
		glow = glow_col_2;
	}
	//pupil
	if (uv.x > eyePos.x - pupilSize.x*0.5*eyeScale && uv.x < eyePos.x + pupilSize.x*0.5*eyeScale && uv.y > eyePos.y - pupilSize.y*0.5*eyeScale && uv.y < eyePos.y + pupilSize.y * 0.5*eyeScale){
		color = pupilColor;
		glow = glow_col;
	}
	//gradient shadow
	color = (UV.y*2.0-eyeLids.x+2.0)*0.95*color;
	
	
	//highlight
	vec2 hlp = vec2(highlightPos.x + eyePos.x*highlightTrackIntensity, highlightPos.y + eyePos.y*highlightTrackIntensity);
	if (uv.x > hlp.x - highlightSize.x && uv.x < hlp.x + highlightSize.x && uv.y > hlp.y - highlightSize.y && uv.y < hlp.y + highlightSize.y){
		//color = vec3(255.0,255.0,255.0);
		color = vec3(1.0,1.0,1.0);
	}
	//EMISSION = glow_col*4.0;
	//eyelashes
	if (uv.y + cos(uv.x)*(eyelashTaper+eyeTaper) < eyeLids.x + eyelashes.x-1.5) {
		color = eyelashCol;
		glow = vec3(0.0,0.0,0.0);
		EMISSION = vec3(0.0,0.0,0.0);
	}
	if (uv.y - cos(uv.x)*(eyelashTaper+eyeTaper*0.25) > eyeLids.y - eyelashes.y+0.5) {
		color = eyelashCol;
		glow = vec3(0.0,0.0,0.0);
		EMISSION = vec3(0.0,0.0,0.0);
	}
	
	EMISSION = glow*4.0;
	//EMISSION = color*0.25;
	ALBEDO = color;
	float trans = 1.0 - (transparency*(1.0-ALBEDO.g));
	if (uv.y + cos(uv.x)* eyeTaper < eyeLids.x-1.5) {
		trans = 0.0;
	}
	if (uv.y - cos(uv.x)* eyeTaper*0.25 > eyeLids.y+0.5) {
		trans = 0.0;
	}
	ALPHA = trans;
}
