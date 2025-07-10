extends StaticBody3D

# global variables
var g_Velocity = 0.0

###
# Fires a projectile
#@param force - force to apply to the projectile
##
func fire(force: float):
	g_Velocity = absf(force)

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _physics_process(delta):
	# move the projectile forward
	global_position.z -= g_Velocity * delta

###
# Called when the projectile goes out of the screen
##
func _on_visibility_notifier_screen_exited():
	# delete the projectile
	queue_free()
