extends Node3D

# signals
signal can_enter_portal(canEnter)

###
# Called when a body enters in the trigger zone
#param body - body which entered in the trigger zone
##
func _on_trigger_zone_body_entered(body):
	# ignore any body but player
	if body.name != "Player":
		return

	# player is in trigger zone, can enter the portal
	can_enter_portal.emit(true)

###
# Called when a body leaves the trigger zone
#param body - body which leaved the trigger zone
##
func _on_trigger_zone_body_exited(body):
	# ignore any body but player
	if body.name != "Player":
		return

	# player is no longer in trigger zone, cannot enter the portal
	can_enter_portal.emit(false)
