extends StaticBody3D

# components
@onready var m_TopFlashLight:    Node3D = $Model/Light1
@onready var m_BottomFlashLight: Node3D = $Model/Light2

# signals
signal can_use_elevator(canUse, elevator)

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	pass # Replace with function body.

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _process(delta):
	pass

###
# Called when a body enters in the trigger zone
#param body - body which entered in the trigger zone
##
func _on_trigger_zone_body_entered(body):
	# ignore any body but player
	if body.name != "Player":
		return

	m_TopFlashLight.light_fade_in()
	m_BottomFlashLight.light_fade_in()

###
# Called when a body leaves the trigger zone
#param body - body which leaved the trigger zone
##
func _on_trigger_zone_body_exited(body):
	# ignore any body but player
	if body.name != "Player":
		return

	m_TopFlashLight.light_fade_out()
	m_BottomFlashLight.light_fade_out()
