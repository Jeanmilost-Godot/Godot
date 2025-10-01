extends Path3D

# children instances
@onready var m_Root       = $".."
@onready var m_PathFollow = $PathFollow
@onready var m_Head       = $PathFollow/SculptedHead

# variables
var m_Speed            = 0.75
var m_PrevProgress     = 0.0
var m_Angle            = 0.0
var m_Offset           = 1.0
var m_TimeToWait       = 1.0
var m_WaitTimer        = 0.0
var m_IsWaiting        = false
var m_ProjectilesFired = false
var m_ProjectileAngles = [135, 180, 225]

###
# Fires the projectiles
##
func fire_projectiles():
	m_ProjectilesFired = true;

	# iterate through projectiles to fire
	for i in range(m_ProjectileAngles.size()):
		# create a projectile and attach it to the scene
		var projectile = preload("res://scenes/projectile.tscn").instantiate()
		get_tree().current_scene.add_child(projectile)

		# place it in the scene
		projectile.global_position    = m_Head.global_position
		projectile.global_position.y += 10

		# fire the projectile
		projectile.fire_head(m_ProjectileAngles[i], 10.0)

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
	m_Angle += m_Speed * delta

	if (m_Angle >= PI / 2):
		m_Angle = PI / 2

	m_PathFollow.progress_ratio = 1.0 - cos(m_Angle)

	# do fire a projectile?
	if !m_ProjectilesFired && m_PathFollow.progress_ratio >= 0.35:
		fire_projectiles()

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
