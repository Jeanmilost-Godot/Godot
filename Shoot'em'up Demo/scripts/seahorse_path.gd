extends Path3D

# children instances
@onready var m_Root       = $".."
@onready var m_PathFollow = $PathFollow

# variables
var m_Speed  = 0.7
var m_CurPos = 0.0

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
	# calculate next position
	m_CurPos += m_Speed * delta

	# path end reached?
	if (m_CurPos >= 1.0):
		m_CurPos = 1.0

	m_PathFollow.progress_ratio = m_CurPos

###
# Called when the path end was reached
##
func on_path_completed():
	# delete the shark
	m_Root.queue_free()
