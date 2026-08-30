shader_type spatial;
render_mode cull_disabled;
uniform vec3 albedo_color : source_color = vec3(1.0,1.0,1.0);
uniform sampler2D albedo_texture : source_color;
uniform sampler2D shadows_helper_texture : hint_default_black;
uniform float luminance_shadow_power : hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float luminance_shadow_cuttoff = 1.0;
uniform sampler2D luminance_gradient : source_color, hint_default_black;
uniform float specular_power = 0.0;
uniform float roughness = 1.0;
uniform float metallic = 0.0;

void fragment() {
	vec2 base_uv = UV;
	vec3 albedo = texture(albedo_texture,base_uv).rgb;
	ALBEDO = albedo * albedo_color;
	ROUGHNESS = roughness;
	METALLIC = metallic;
	
}


float D_GGX(float cos_theta_m, float alpha)
{
float alpha2 = alpha * alpha;
float d = 1.0 + (alpha2 - 1.0) * cos_theta_m * cos_theta_m;
return alpha2 / (PI * d * d);
}

float G_GGX_2cos(float cos_theta_m, float alpha)
{
float k = 0.5 * alpha;
return 0.5 / (cos_theta_m * (1.0 - k) + k);
}

vec3 F0(float metallic_c, float specular_c, vec3 albedo_c)
{
float dielectric = 0.16 * specular_c * specular_c;
return mix(vec3(dielectric), albedo_c, vec3(metallic_c));
}


float SchlickFresnel(float u)
{
float m = 1.0 - u;
float m2 = m * m;
return m2 * m2 * m;
}


void light()
{
	//shadow
	float shadow = ATTENUATION;
	vec3 shadow_helper = texture(shadows_helper_texture,UV).rgb;
	shadow *= (1.0-shadow_helper.g);
	shadow *= (1.0 - shadow_helper.r*(1.0-(dot(NORMAL, LIGHT))));
	
	//diffuse light
	float luminance = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	if (luminance > luminance_shadow_cuttoff){
		luminance = 1.0;
	}
	float true_luminance = 0.5*dot(NORMAL,LIGHT)+0.5;
	luminance = mix(luminance,true_luminance,1.0-luminance_shadow_power)*shadow;
	vec3 luminance_adjustment = texture(luminance_gradient,vec2(true_luminance,0.0)).rgb;
	DIFFUSE_LIGHT +=  luminance * LIGHT_COLOR + luminance_adjustment*LIGHT_COLOR*ATTENUATION;
	vec3 inverse_d_l = clamp(dot(-NORMAL, LIGHT), 0.0, 1.0)*ATTENUATION * LIGHT_COLOR + luminance_adjustment*LIGHT_COLOR*ATTENUATION;
	DIFFUSE_LIGHT += inverse_d_l*BACKLIGHT;
	float Ro = ((1.0 - 0.5)/1.0 + 0.5);
	Ro *= Ro;
	
	
	//specular light
	float specular = specular_power * (1.0-shadow_helper.b);
	
	vec3 halfway = normalize(VIEW + LIGHT);
	float NdotH = max(dot(NORMAL, halfway), 0.0);
	float LdotH = max(dot(LIGHT, halfway), 0.0);
	float NdotV = max(dot(NORMAL, VIEW), 0.0);
	
	float alpha_ggx = ROUGHNESS * ROUGHNESS;
	float D = D_GGX(NdotH, alpha_ggx) ;
	float NdotL = specular;//mix(specular_highlight,specular_highlight_day,sh_day_power*day_color_influence);
	float G = G_GGX_2cos(NdotL, alpha_ggx) * G_GGX_2cos(NdotV, alpha_ggx);    
	
	vec3 f0 = F0(METALLIC, SPECULAR_AMOUNT, ALBEDO);
	float cLdotH5 = SchlickFresnel(LdotH);
	vec3 F = mix(vec3(cLdotH5), vec3(1.0), f0);
	
	vec3 specular_brdf_NL = NdotL * D * F * G;
	
	float specular_blob_intensity = 0.25;
	SPECULAR_LIGHT += specular_brdf_NL * LIGHT_COLOR * specular_blob_intensity * ATTENUATION;
}
