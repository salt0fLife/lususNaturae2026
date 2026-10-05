extends Node3D
var check_distance = 100.0

func in_sunlight_pecentage():
#	var time = PlayerInformation.world_time
	var time = Global.world_time
	if time > 0.5: #is night
		return 0.0
#	var multiplier = (sin(time*2.0*PI)+1.0)*0.5*(1.0-PlayerInformation.world_overcast)
	var multiplier = (sin(time*2.0*PI)+1.0)*0.5*(1.0-Global.world_overcast)
	var sun_rotation = Vector3(-PI*time*2.0,-0.9,2.76)
	var val = 0.0
	var child_count = get_child_count(false)
	for r in get_children(false):
		r.target_position = Vector3(0.0,0.0,check_distance)
		r.rotation = sun_rotation
		if !r.is_colliding(): #is in sun
			val += 1.0/child_count
	return val*multiplier

##TIME and TEXTURE3D are a problem :/
#func get_cloud_shadow():
	#var SunshineClouds_SunDirection = Vector3.UP
	#var SunshineClouds_CloudsFloor = 0.0
	#var TIME = 0.0
	#
	#var CLOUD_SHADOW_STRENGTH:float = 0.5;
	#var cast_shadow:float = 1.0#ATTENUATION;#clamp(ATTENUATION * 2.0 - 1.0, 0, 1.5);
	#var origin:Vector3 = global_position#fragment_worldpos;
	#var angleUpward:float = clamp(2.0 - (((SunshineClouds_SunDirection.dot(Vector3(0.0, 1.0, 0.0)) + 1.0)) * 180.0), 0.0, 180.0);
	#origin += SunshineClouds_SunDirection;
	#
	#if (origin.y < SunshineClouds_CloudsFloor):
		#var lengthToTravel:float = (SunshineClouds_CloudsFloor + 200.0) - origin.y / sin(90.0 - angleUpward);
		#origin += SunshineClouds_SunDirection * lengthToTravel;
	#else:
		#origin += SunshineClouds_SunDirection * 200.0;
	#var cloud_shadow:float = (1.0 - clamp(samplecloudmap(origin, TIME) * CloudDensity, 0.0, 1.0));
	#var cur_pos:Vector3 = origin;
	#var shadow:float = mix(ATTENUATION, cast_shadow * (clamp(cloud_shadow * 3.0 - 1.0, 0.0, 1.0) * CLOUD_SHADOW_STRENGTH), CloudOpacity);
	#pass

func get_sun_rotation() -> Vector3:
	#var time = PlayerInformation.world_time
	var time = Global.world_time
	if time > 0.5:
		return Vector3.ZERO;
	return Vector3(-PI*time*2.0,-0.9,2.76)
