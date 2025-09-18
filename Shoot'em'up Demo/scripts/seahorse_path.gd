extends Path3D

# children instances
@onready var m_Root       = $".."
@onready var m_PathFollow = $PathFollow
@onready var m_Seahorse   = $PathFollow/Seahorse

# variables
var m_Speed                = 0.7
var m_CurPos               = 0.0
var m_ElapsedTime          = 0.0
var m_ProjectilesFired     = false
var m_ProjectilesDiagFired = false

###
# Fires the projectiles
##
func fire_projectiles():
	m_ProjectilesFired = true

	# create a projectile and attach it to the scene
	var projectile = preload("res://scenes/projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = m_Seahorse.global_position
	projectile.fire_seahorse(1)

	projectile = preload("res://scenes/projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = m_Seahorse.global_position
	projectile.fire_seahorse(3)

	projectile = preload("res://scenes/projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = m_Seahorse.global_position
	projectile.fire_seahorse(5)

	projectile = preload("res://scenes/projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = m_Seahorse.global_position
	projectile.fire_seahorse(7)

###
# Fires projectiles on the diagonal
##
func fire_projectiles_diagonal():
	m_ProjectilesDiagFired = true

	# create a projectile and attach it to the scene
	var projectile = preload("res://scenes/projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = m_Seahorse.global_position
	projectile.fire_seahorse(2)

	projectile = preload("res://scenes/projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = m_Seahorse.global_position
	projectile.fire_seahorse(4)

	projectile = preload("res://scenes/projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = m_Seahorse.global_position
	projectile.fire_seahorse(6)

	projectile = preload("res://scenes/projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = m_Seahorse.global_position
	projectile.fire_seahorse(8)

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

		if (!m_ProjectilesFired && m_ElapsedTime >= 1):
			fire_projectiles()

		if (!m_ProjectilesDiagFired && m_ElapsedTime >= 3):
			fire_projectiles_diagonal()

	m_PathFollow.progress_ratio = m_CurPos
