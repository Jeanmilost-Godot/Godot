extends StaticBody3D

# variables
var m_Dir:      Vector2
var m_Speed:    float = 0.0
var m_MinSpeed: float = 50.0
var m_MaxSpeed: float = 200.0

###
# Fires a projectile from a bat
##
func fire_bat():
	# choose a random angle between 165° and 195°
	var minAngle    = deg_to_rad(165)
	var maxAngle    = deg_to_rad(195)
	var randomAngle = randf_range(minAngle, maxAngle)

	# convert angle to direction vector
	m_Dir = Vector2(cos(randomAngle), sin(randomAngle))

	# select random speed within the defined range
	m_Speed = randf_range(m_MinSpeed, m_MaxSpeed)

###
# Fires a projectile from a seahorse
#@param dir - direction, may be:
#              8   7   6
#               \  |  /
#             1 -     - 5
#               /  |  \
#              2   3   4
##
func fire_seahorse(dir):
	var angle

	match dir:
		1: angle = deg_to_rad(180.0)
		2: angle = deg_to_rad(225.0)
		3: angle = deg_to_rad(270.0)
		4: angle = deg_to_rad(315.0)
		5: angle = deg_to_rad(0.0)
		6: angle = deg_to_rad(45.0)
		7: angle = deg_to_rad(90.0)
		8: angle = deg_to_rad(135.0)
		_: return

	# convert angle to direction vector
	m_Dir   = Vector2(cos(angle), sin(angle))
	m_Speed = 100.0

###
# Fires a projectile from a ghast
##
func fire_ghast(angle, speed):
	var fireAngle = deg_to_rad(angle)

	# convert angle to direction vector
	m_Dir = Vector2(cos(fireAngle), sin(fireAngle))

	m_Speed = speed

###
# Called every frame
#@param delta - elapsed time in seconds since the previous call
##
func _process(delta):
	# move the object based on direction and speed
	var movement = Vector3(0, m_Dir.y * m_Speed * delta, -m_Dir.x * m_Speed * delta)

	position += movement

###
# Called when the projectile goes out of the screen
##
func _on_visibility_notifier_screen_exited():
	# delete the projectile
	queue_free()
