class_name entity_base extends CharacterBody3D

func is_out_of_bounds() -> bool:
	return (position - PlayerInformation.position).length() > 400.0
