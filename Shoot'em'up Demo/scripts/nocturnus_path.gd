extends Path3D

# children instances
@onready var m_Root       = $".."
@onready var m_PathFollow = $PathFollow

# variables
var m_Speed        = 175.0
var m_Angle        = 0.0
var m_PrevProgress = 0.0

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	m_PathFollow.progress_ratio = 0.0

###
# Called every frame
#@param delta - elapsed time in seconds since the previous call
##
func _process(delta):
	# apply speed boost in the slow zones (around 90° and 270°)
	var speed_multiplier = 1.0

	# get angle within 0-180 range
	var angle_mod = fmod(m_Angle, 180.0)

	# boost speed when close to 90° (the slow point)
	if angle_mod > 70.0 and angle_mod < 110.0:
		speed_multiplier = 2.5

	# calculate next angle
	m_Angle += m_Speed * delta * speed_multiplier

	# check if half path was reached
	if (m_Angle >= 90.0):
		m_PathFollow.progress_ratio = 1.0 - (0.5 * sin(deg_to_rad(m_Angle)))
	else:
		m_PathFollow.progress_ratio =        0.5 * sin(deg_to_rad(m_Angle))

	# path end reached?
	if m_PathFollow.progress_ratio < m_PrevProgress:
		on_path_completed()

	# keep the current position as previous one
	m_PrevProgress = m_PathFollow.progress_ratio

###
# Called when the path end was reached
##
func on_path_completed():
	# delete the shark
	m_Root.queue_free()
