extends Path3D

# children instances
@onready var m_Root       = $".."
@onready var m_PathFollow = $PathFollow
@onready var m_Ghast      = $PathFollow/Ghast
@onready var m_Animations = $PathFollow/Ghast/AnimationTree

# variables
var m_Speed                = 0.035
var m_CurPos               = 0.0
var m_PrevPos              = 0.0
var m_ProjectileAngles     = [155, 160, 165, 170, 175, 180, 185, 190]
var m_TriggerPositions     = [0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6]
var m_CurTriggerIndex      = 0

###
# Fires the projectiles
##
func fire_projectiles():
	m_Animations.set("parameters/conditions/isIdle",   false)
	m_Animations.set("parameters/conditions/isFiring", true)

	# iterate through projectiles to fire
	for i in range(m_ProjectileAngles.size()):
		# create a projectile and attach it to the scene
		var projectile = preload("res://scenes/projectile.tscn").instantiate()
		get_tree().current_scene.add_child(projectile)

		# place it in the scene
		projectile.global_position    =  m_Ghast.global_position
		projectile.global_position.y += 10

		# fire the projectile
		projectile.fire_ghast(m_ProjectileAngles[i], 20.0)

###
# Checks if projectiles should be fired, fires them if yes
#param prevPos - previous trigger position
#param curPos - current trigger position
##
func check_fire_projectiles(prevPos: float, curPos: float):
	# process multiple triggers in one frame if moving very fast
	while m_CurTriggerIndex < m_TriggerPositions.size():
		# get next trigger position
		var nextTrigger = m_TriggerPositions[m_CurTriggerIndex]

		# do fire the projectiles?
		if prevPos < nextTrigger and curPos >= nextTrigger:
			# fire the projectiles
			fire_projectiles()

			# increment the trigger index to the next position
			m_CurTriggerIndex += 1
		else:
			# no more triggers to process this frame
			break

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	m_Animations.connect("animation_finished", on_animation_finished)

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

	# check if the projectiles should be fired, fire them if yes
	check_fire_projectiles(m_PrevPos, m_CurPos)

	# set next path position
	m_PathFollow.progress_ratio = m_CurPos

	# keep the previous position
	m_PrevPos = m_CurPos

###
# Called when the path end was reached
##
func on_path_completed():
	# delete the shark
	m_Root.queue_free()

###
# Called when an animation finished
#@param anim_name - animation name which just finished
##
func on_animation_finished(anim_name):
	m_Animations.set("parameters/conditions/isIdle", true)
