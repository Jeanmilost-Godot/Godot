extends Path3D

# children instances
@onready var m_Root       = $".."
@onready var m_PathFollow = $PathFollow
@onready var m_Seahorse   = $PathFollow/Seahorse

# variables
var m_Speed               = 0.7
var m_CurPos              = 0.0
var m_ElapsedTime         = 0.0
var m_ProjectileIndex     = [1, 3, 5, 7]
var m_ProjectileDiagIndex = [2, 4, 6, 8]
var m_ProjectilesFired    = [false, false, false, false]

###
# Fires the projectiles
#@param index - fired projectile index
#@param projectileArray - array containing projectile index to fire
##
func fire_projectiles(index, projectileArray):
	m_ProjectilesFired[index] = true

	for i in range(projectileArray.size()):
		# create a projectile and attach it to the scene
		var projectile = preload("res://scenes/projectile.tscn").instantiate()
		get_tree().current_scene.add_child(projectile)

		projectile.global_position = m_Seahorse.global_position
		projectile.fire_seahorse(projectileArray[i])

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

		m_ElapsedTime += delta

		if (!m_ProjectilesFired[0] && m_ElapsedTime >= 1):
			fire_projectiles(0, m_ProjectileIndex)
		elif (!m_ProjectilesFired[1] && m_ElapsedTime >= 2):
			fire_projectiles(1, m_ProjectileDiagIndex)
		elif (!m_ProjectilesFired[2] && m_ElapsedTime >= 3):
			fire_projectiles(2, m_ProjectileIndex)
		elif (!m_ProjectilesFired[3] && m_ElapsedTime >= 4):
			fire_projectiles(3, m_ProjectileDiagIndex)

	m_PathFollow.progress_ratio = m_CurPos
