extends Path3D

# children instances
@onready var m_Root       = $".."
@onready var m_PathFollow = $PathFollow
@onready var m_Spider     = $PathFollow/Spider

# variables
var m_Speed  = 0.75
var m_Offset = 1.0
var m_Pos    = 0.0

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
	m_Pos += m_Speed * delta * m_Offset

	if m_Pos <= 0.0:
		m_Pos = 0.0
		m_Offset = 1.0
	elif m_Pos >= 1.0:
		m_Pos = 1.0
		m_Offset = -1.0

	m_PathFollow.progress_ratio = m_Pos
