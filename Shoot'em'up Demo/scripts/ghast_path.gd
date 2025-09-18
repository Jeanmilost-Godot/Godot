extends Path3D

# children instances
@onready var m_Root       = $".."
@onready var m_PathFollow = $PathFollow
@onready var m_Ghast      = $PathFollow/Ghast
@onready var m_Animations = $PathFollow/Ghast/AnimationTree

# variables
var m_Speed                = 0.1
var m_CurPos               = 0.0
var m_PrevPos              = 0.0

#var trigger_positions = [0.2, 0.21, 0.22, 0.23, 0.3, 0.31, 0.32, 0.33, 0.4, 0.41, 0.42, 0.43, 0.5, 0.51, 0.52, 0.53, 0.6, 0.61, 0.62, 0.63, 0.7, 0.71, 0.72, 0.73]
var trigger_positions = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6]
var current_trigger_index = 0

var m_ProjectileAngles     = [160, 165, 170, 175]
var m_ProjectileAngleIndex = 0

###
# Fires a  projectile
##
func fire_projectiles():
	m_Animations.set("parameters/conditions/isIdle",   false)
	m_Animations.set("parameters/conditions/isFiring", true)
	
	# create a projectile and attach it to the scene
	var projectile = preload("res://scenes/projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = m_Ghast.global_position
	#projectile.fire_ghast(m_ProjectileAngles[m_ProjectileAngleIndex], 10.0)
	projectile.fire_ghast(160, 20.0)

	#m_ProjectileAngleIndex += 1
	
	#if (m_ProjectileAngleIndex >= m_ProjectileAngles.size()):
		#m_ProjectileAngleIndex = 0

	projectile = preload("res://scenes/projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = m_Ghast.global_position
	projectile.fire_ghast(165, 20.0)

	projectile = preload("res://scenes/projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = m_Ghast.global_position
	projectile.fire_ghast(170, 20.0)

	projectile = preload("res://scenes/projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = m_Ghast.global_position
	projectile.fire_ghast(175, 20.0)

func check_triggers(previous_pos: float, current_pos: float):
	# process multiple triggers in one frame if moving very fast
	while current_trigger_index < trigger_positions.size():
		var next_trigger = trigger_positions[current_trigger_index]

		if previous_pos < next_trigger and current_pos >= next_trigger:
			fire_projectiles()
			current_trigger_index += 1
		else:
			# No more triggers to process this frame
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

	check_triggers(m_PrevPos, m_CurPos)

	m_PathFollow.progress_ratio = m_CurPos
	
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
