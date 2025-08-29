extends StaticBody3D

# variables
var m_Dir:      Vector2
var m_Speed:    float = 0.0
var m_MinSpeed: float = 50.0
var m_MaxSpeed: float = 200.0

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	# choose a random angle between 165° and 195°
	var minAngle    = deg_to_rad(165)
	var maxAngle    = deg_to_rad(195)
	var randomAngle = randf_range(minAngle, maxAngle)

	# convert angle to direction vector
	m_Dir = Vector2(cos(randomAngle), sin(randomAngle))

	# select random speed within the defined range
	m_Speed = randf_range(m_MinSpeed, m_MaxSpeed)

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
