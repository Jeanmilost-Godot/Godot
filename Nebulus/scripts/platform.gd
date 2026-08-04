extends StaticBody3D

# variables
var m_Velocity: float = 0.0

# signals
signal do_player_swip(swip, dir)

###
# Called when a body enters in the swipping zone
#param body - body which entered in the trigger zone
##
func _on_sliding_area_body_entered(body):
	# ignore any body but player
	if body.name != "Player":
		return

	do_player_swip.emit(true, m_Velocity)

###
# Called when a body leaves in the swipping zone
#param body - body which entered in the trigger zone
##
func _on_sliding_area_body_exited(body):
	# ignore any body but player
	if body.name != "Player":
		return

	do_player_swip.emit(false, 0.0)
