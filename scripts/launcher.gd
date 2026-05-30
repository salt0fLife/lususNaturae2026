extends Area3D
@export var add_vel : Vector3 = Vector3.ZERO



func _on_body_entered(body):
	body.velocity += add_vel
