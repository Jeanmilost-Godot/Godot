extends PathFollow3D

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	# disable automatic rotation
	rotation_mode = PathFollow3D.ROTATION_NONE

	# restore the original rotation
	rotation_degrees = Vector3(0, 0, 0)
