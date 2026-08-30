//global uniform vec3 SunshineClouds_SunDirection;

uniform float specular_highlight = 0.01;
uniform float specular_highlight_day = 0.01;
uniform float sh_day_power :hint_range(0.0, 1.0) = 0.0;
global uniform float day_color_influence;

global uniform vec2 SunshineClouds_WindDirection;
global uniform float SunshineClouds_WindSpeed;

global uniform float SunshineClouds_CloudsGlobalScale;
global uniform float SunshineClouds_CloudsBaseNoiseScale;
global uniform float SunshineClouds_CloudsDetailNoiseScale;
global uniform float SunshineClouds_CloudsDetailNoisePower;
global uniform float SunshineClouds_CloudsLargeScaleNoiseScale;
global uniform float SunshineClouds_CloudsLargeScaleNoisePower;

global uniform float SunshineClouds_CloudsFloor;
global uniform float SunshineClouds_CloudsCeiling;
global uniform float SunshineClouds_CloudsCutoff;

global uniform vec3 SunshineClouds_SunDirection;
global uniform sampler3D SunshineClouds_BaseNoiseTexture;
global uniform sampler3D SunshineClouds_DetailNoiseTexture;
global uniform sampler3D SunshineClouds_LargeScaleNoiseTexture;

global uniform sampler2D SunshineClouds_HeightWeightGradient;

global uniform float SunshineClouds_CloudShadowStrength;
global uniform float SunshineClouds_ShapeSpeedMultiplier;
global uniform vec3 SunshineClouds_StartingOffset;

group_uniforms LightingAdjustments;
uniform sampler2D luminance_gradient : repeat_disable, hint_default_black;
//uniform float gradient_shadow_effect : hint_range(0.0, 1.0, 0.01) = 0.0;

group_uniforms DensityControls;
uniform float CloudDitherPower = 10.0;
uniform float CloudCutoffAdjust = -0.795;
uniform float CloudDensity = 1.49;
uniform float CloudOpacity: hint_range(0,1) = 1.0;
uniform float cloudSoftness = 0.85;

varying vec3 fragment_worldpos;
const mat4 dither_matrix = mat4(
  vec4(0.0625, 0.5625, 0.1875,  0.6875),
  vec4(0.8125, 0.3125, 0.9375,  0.4375),
  vec4(0.25, 0.75, 0.125, 0.625),
  vec4(1.0, 0.5, 0.875,  0.375)
);



//float samplecloudmap(vec3 pos, float time) {
	//float heightSample = smoothstep(SunshineClouds_CloudsCeiling,SunshineClouds_CloudsCeiling - 100.0, pos.y);
	//float heightScale = (pos.y - SunshineClouds_CloudsFloor) / (SunshineClouds_CloudsCeiling - SunshineClouds_CloudsFloor);
	////pos.y = clamp(pos.y, SunshineClouds_CloudsFloor, SunshineClouds_CloudsCeiling);
	//pos /= SunshineClouds_CloudsGlobalScale;
	//
////	float largeScaleNoise = textureLod(SunshineClouds_LargeScaleNoiseTexture, pos * (SunshineClouds_CloudsLargeScaleNoiseScale) + (vec3(SunshineClouds_WindDirection.x, 0.0, SunshineClouds_WindDirection.y) * time * SunshineClouds_WindSpeed / 4.0), 1.0).r * SunshineClouds_CloudsLargeScaleNoisePower;
	//float largeScaleNoise = textureLod(SunshineClouds_LargeScaleNoiseTexture, SunshineClouds_StartingOffset + pos * (SunshineClouds_CloudsLargeScaleNoiseScale) + (vec3(SunshineClouds_WindDirection.x, 0.0, SunshineClouds_WindDirection.y) * time *SunshineClouds_ShapeSpeedMultiplier * SunshineClouds_WindSpeed / 4.0), 1.0).r * SunshineClouds_CloudsLargeScaleNoisePower;
	////BE ^^^
	////float largeScaleNoise = texture(LargeShapeNoiseTexture, vec3(pos.x, pos.y * 0.5, pos.z) * (large_scale_noise_scale) + vec3(WindDirection.x, 0.0, WindDirection.y) * time * WindSpeed / 3.0).r * large_scale_noise_power;
	//
	////if (largeScaleNoise > 1.0){return 0.0;}
	//heightScale = texture(SunshineClouds_HeightWeightGradient, vec2(heightScale, 0.0)).r;
	//
	//float noise = textureLod(SunshineClouds_BaseNoiseTexture, pos * (SunshineClouds_CloudsBaseNoiseScale) + vec3(SunshineClouds_WindDirection.x, 0.0, SunshineClouds_WindDirection.y) * time * SunshineClouds_WindSpeed, 1.0).r; 
	////+ textureLod(SunshineClouds_DetailNoiseTexture, pos * (SunshineClouds_CloudsDetailNoiseScale) - (vec3(SunshineClouds_WindDirection.x, 0.0, SunshineClouds_WindDirection.y) * time * SunshineClouds_WindSpeed / 3.0), 1.0).r * SunshineClouds_CloudsDetailNoisePower;
	////BE does not need to be as detailed ^^^
	//
	//
	//noise -= largeScaleNoise;
	////noise = posCutoff;
	//noise = smoothstep(SunshineClouds_CloudsCutoff + CloudCutoffAdjust, SunshineClouds_CloudsCutoff + cloudSoftness, noise);
	//
	/////NOTE these make intensity scale with distance away
	////noise *= heightScale;
	////noise *= heightSample;
	//
	////noise = clamp(noise, 0.0, posCutoff);
	////noise -= posCutoff;f
	////noise = clamp(noise, 0.0, abs(clamp(pos.y, CloudFloor, CloudCeiling) - pos.y));
	////noise -= distance(pos.y, clamp(pos.y, CloudFloor, CloudCeiling));
	////noise *= posCutoff;
	//return noise;
//}

float samplecloudmap(vec3 pos, float time) {
	//if (abs(clamp(pos.y, CloudFloor, CloudCeiling) - pos.y) > 0.0){return 0.0;}
	float heightScale = (pos.y - SunshineClouds_CloudsFloor) / (SunshineClouds_CloudsCeiling - SunshineClouds_CloudsFloor);
	float posCutoff = smoothstep(0.0, 0.001, heightScale) - smoothstep(1.0, 1.001, heightScale);
	posCutoff = smoothstep(0.0, 0.001, posCutoff);
	//float posCutoff = abs(clamp(distance(clamp(pos.y, CloudFloor, CloudCeiling), pos.y), 0.0, 1.0) - 1.0);
	//if (distance(clamp(pos.y, CloudFloor, CloudCeiling), pos.y) > 0.0){posCutoff = 1.0;}
	pos /= SunshineClouds_CloudsGlobalScale;

	//float largeScaleNoise = textureLod(SunshineClouds_LargeScaleNoiseTexture, pos * (SunshineClouds_CloudsLargeScaleNoiseScale) + (vec3(SunshineClouds_WindDirection.x, 0.0, SunshineClouds_WindDirection.y) * time * SunshineClouds_WindSpeed / 4.0), 100.0).r * SunshineClouds_CloudsLargeScaleNoisePower;
	//BE VVV
	float largeScaleNoise = textureLod(SunshineClouds_LargeScaleNoiseTexture, SunshineClouds_StartingOffset + pos * (SunshineClouds_CloudsLargeScaleNoiseScale) + (vec3(SunshineClouds_WindDirection.x, 0.0, SunshineClouds_WindDirection.y) * time *SunshineClouds_ShapeSpeedMultiplier * SunshineClouds_WindSpeed / 4.0), 1.0).r * SunshineClouds_CloudsLargeScaleNoisePower;
	//largeScaleNoise += 1.0 - posCutoff;
	if (posCutoff <= 0.0){return 0.0;}
	//float largeScaleNoise = texture(LargeShapeNoiseTexture, vec3(pos.x, pos.y * 0.5, pos.z) * (large_scale_noise_scale) + vec3(WindDirection.x, 0.0, WindDirection.y) * time * WindSpeed / 3.0).r * large_scale_noise_power;

	//if (largeScaleNoise > 1.0){return 0.0;}

	heightScale = texture(SunshineClouds_HeightWeightGradient, vec2(heightScale, 0.0)).r;

	float noise = textureLod(SunshineClouds_BaseNoiseTexture, pos * (SunshineClouds_CloudsBaseNoiseScale) + vec3(SunshineClouds_WindDirection.x, 0.0, SunshineClouds_WindDirection.y) * time * SunshineClouds_WindSpeed, 100.0).r
	//+ textureLod(SunshineClouds_DetailNoiseTexture, pos * (SunshineClouds_CloudsDetailNoiseScale)*0.2 - (vec3(SunshineClouds_WindDirection.x, 0.0, SunshineClouds_WindDirection.y) * time * SunshineClouds_WindSpeed / 3.0), 100.0).r * SunshineClouds_CloudsDetailNoisePower*0.5
	+ textureLod(SunshineClouds_DetailNoiseTexture, pos * (SunshineClouds_CloudsDetailNoiseScale) - (vec3(SunshineClouds_WindDirection.x, 0.0, SunshineClouds_WindDirection.y) * time * SunshineClouds_WindSpeed / 3.0), 100.0).r * SunshineClouds_CloudsDetailNoisePower;


	noise *= heightScale;
	noise -= largeScaleNoise;
	//noise = posCutoff;
	noise = smoothstep(SunshineClouds_CloudsCutoff, SunshineClouds_CloudsCutoff + cloudSoftness, noise);
	//noise = clamp(noise, 0.0, posCutoff);
	//noise -= posCutoff;f
	//noise = clamp(noise, 0.0, abs(clamp(pos.y, CloudFloor, CloudCeiling) - pos.y));
	//noise -= distance(pos.y, clamp(pos.y, CloudFloor, CloudCeiling));
	//noise *= posCutoff;
	return noise;
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
	//bool disabled_shadows = (SunshineClouds_CloudShadowStrength == 0.0);
	if (LIGHT_IS_DIRECTIONAL){
		float cloud_shadow = 1.0;
		float shadow = ATTENUATION;
		if (SunshineClouds_CloudShadowStrength > 0.0){
			const float CLOUD_SHADOW_STRENGTH = 0.5;
			float cast_shadow = ATTENUATION;//clamp(ATTENUATION * 2.0 - 1.0, 0, 1.5);
			//float upDot = (dot(SunshineClouds_SunDirection, vec3(0.0, 1.0, 0.0)) + 1.0) / 2.0;
			
			float dither = dither_matrix[int(FRAGCOORD.x + TIME * 100.0) % 4][int(FRAGCOORD.y + TIME * 100.0) % 4];
			
			dither = (dither * CloudDitherPower) - CloudDitherPower / 2.0;
			vec3 origin = fragment_worldpos;
			float angleUpward = clamp(2.0 - ((dot(SunshineClouds_SunDirection, vec3(0.0, 1.0, 0.0)) + 1.0)) * 180.0, 0.0, 180.0);
			origin += SunshineClouds_SunDirection * dither;
			
			if (origin.y < SunshineClouds_CloudsFloor){
				float lengthToTravel = (SunshineClouds_CloudsFloor + 200.0) - origin.y / sin(90.0 - angleUpward);
				
				//origin += SunshineClouds_SunDirection * dither;
				origin += SunshineClouds_SunDirection * lengthToTravel;
			}
			else
			{
				origin += SunshineClouds_SunDirection * 200.0;
			}
			//origin.y = max(origin.y, SunshineClouds_CloudsFloor + 200.0);
			//float cloud_shadow = 1.0;//(1.0 - clamp(samplecloudmap(origin, TIME) * CloudDensity, 0.0, 1.0));
			//cloud_shadow = 1.0;
			//BE all below vvv
			//vec3 cur_pos = origin;
			//float ground_exposure = 0.0;
			//for (int i = 0; i < 64; i++) {
				//cur_pos += SunshineClouds_SunDirection*100.0;
				//cloud_shadow -= (1.0 - clamp(samplecloudmap(cur_pos, TIME) * CloudDensity, 0.0, 1.0));
			//}
			//cloud_shadow = ground_exposure;
			//BE all above ^^^
			
			
			//NOTE TESTING STEPPING
			vec3 cur_pos = origin;
			float currentDensity = 0.0;
			float thisDensity = 0.0;
			vec3 currentColor = vec3(0.5);
			float cutoffvalue = 0.0;
			
			for (int i = 0; i < 32; i++) {
				cur_pos += 50.0*SunshineClouds_SunDirection;
				thisDensity = 10.0*samplecloudmap(cur_pos, TIME)  * CloudDensity;
				currentDensity += thisDensity * 0.015625; //0.015625 == 1/64
			}
			cloud_shadow = (1.0 - clamp(currentDensity * CloudDensity, 0.0, 1.0));
			//END STEPPIING TESTING
			shadow = mix(ATTENUATION, cast_shadow * (clamp(cloud_shadow * 3.0 - 1.0, 0.0, 1.0) * CLOUD_SHADOW_STRENGTH), CloudOpacity);
		}
		
		shadow = mix(ATTENUATION,shadow,SunshineClouds_CloudShadowStrength);
		
		float luminance = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
		float true_luminance = 0.5*dot(NORMAL,LIGHT)+0.5;
		vec3 luminance_adjustment = texture(luminance_gradient,vec2(true_luminance,0.0)).rgb;
		//vec3 shadow_col = mix(BACKLIGHT,vec3(1.0,1.0,1.0),shadow);
		DIFFUSE_LIGHT +=  luminance * shadow * LIGHT_COLOR + luminance_adjustment*LIGHT_COLOR*shadow;
		vec3 inverse_d_l = clamp(dot(-NORMAL, LIGHT), 0.0, 1.0)* shadow * LIGHT_COLOR + luminance_adjustment*LIGHT_COLOR*shadow;
		DIFFUSE_LIGHT += inverse_d_l*BACKLIGHT;
		//SPECULAR_LIGHT +=  clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * shadow * LIGHT_COLOR;
	}
	else{
		float luminance = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION;
		float true_luminance = 0.5*dot(NORMAL,LIGHT)+0.5;
		vec3 luminance_adjustment = texture(luminance_gradient,vec2(true_luminance,0.0)).rgb;
		//vec3 luminance_adjustment = texture(luminance_gradient,vec2(luminance,0.0)).rgb;
		DIFFUSE_LIGHT +=  luminance * LIGHT_COLOR + luminance_adjustment*LIGHT_COLOR*ATTENUATION;
		vec3 inverse_d_l = clamp(dot(-NORMAL, LIGHT), 0.0, 1.0)*ATTENUATION * LIGHT_COLOR + luminance_adjustment*LIGHT_COLOR*ATTENUATION;
		DIFFUSE_LIGHT += inverse_d_l*BACKLIGHT;
		float Ro = ((1.0 - 0.5)/1.0 + 0.5);
		Ro *= Ro;
	}
	
	// Specular light.
	vec3 halfway = normalize(VIEW + LIGHT);
	float NdotH = max(dot(NORMAL, halfway), 0.0);
	float LdotH = max(dot(LIGHT, halfway), 0.0);
	float NdotV = max(dot(NORMAL, VIEW), 0.0);
	
	float alpha_ggx = ROUGHNESS * ROUGHNESS;
	float D = D_GGX(NdotH, alpha_ggx);
	float NdotL = mix(specular_highlight,specular_highlight_day,sh_day_power*day_color_influence);
	float G = G_GGX_2cos(NdotL, alpha_ggx) * G_GGX_2cos(NdotV, alpha_ggx);    
	
	vec3 f0 = F0(METALLIC, SPECULAR_AMOUNT, ALBEDO);
	float cLdotH5 = SchlickFresnel(LdotH);
	vec3 F = mix(vec3(cLdotH5), vec3(1.0), f0);
	
	vec3 specular_brdf_NL = NdotL * D * F * G;
	
	float specular_blob_intensity = 0.25;
	SPECULAR_LIGHT += specular_brdf_NL * LIGHT_COLOR * specular_blob_intensity * ATTENUATION;
	
}
