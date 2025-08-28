extends Path3D

# children instances
@onready var m_Root       = $".."
@onready var m_PathFollow = $PathFollow
@onready var m_Bat        = $PathFollow/Bat

# variables
var m_Speed         = 1.5
var m_PrevProgress  = 0.0
var m_Angle         = 0.0
var m_Offset        = 1.0
var m_TimeToWait    = 1.0
var m_WaitTimer     = 0.0
var m_IsWaiting     = false
var projectileFired = false

###
# Fires a projectile
##
func fire_projectile():
	projectileFired = true

	# create a projectile and attach it to the scene
	var projectile = preload("res://scenes/projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position    = m_Bat.global_position
	projectile.global_position.y += 5.0
	#projectile.fire(200.0)

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
	# wait for 1 second before continuing the path
	if m_IsWaiting:
		m_WaitTimer += delta

		# do continue the path?
		if m_WaitTimer >= m_TimeToWait:
			m_WaitTimer = 0.0
			m_IsWaiting = false
			m_Angle     = PI / 2.0
			m_Offset    = -m_Offset

		return

	# move along the path, on the first part decelerate, on the second one, accelerate
	if (m_Offset > 0):
		m_PathFollow.progress_ratio = 0.29 * sin(m_Angle)
	else:
		m_PathFollow.progress_ratio = 0.29 + (0.71 - (0.71 * sin(m_Angle)))

	# calculate next position
	m_Angle += m_Speed * m_Offset * delta

	# was the middle of the path reached?
	if (m_Angle >= PI / 2.0):
		m_IsWaiting = true

	# do fire a projectile?
	if !projectileFired && m_PathFollow.progress_ratio >= 0.29:
		fire_projectile()

	# path end reached?
	if m_PathFollow.progress_ratio < m_PrevProgress:
		on_path_completed()

	# keep the current position as previous one
	m_PrevProgress = m_PathFollow.progress_ratio

###
# Called when the path end was reached
##
func on_path_completed():
	# delete the bat
	m_Root.queue_free()
