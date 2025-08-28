###
# Game entity
#@author Jean-Milost Reymond
##
class_name Entity

extends RefCounted

# variables
var m_Scene:    PackedScene
var m_StartPos: Vector3
var m_SpawnPos: float = 0.0
var m_Spawned:  bool  = false

###
# Constructor
#@param scene - preloaded scene to spawn
#@param startPos - scene start position in the parent scene
#@param spawnPos - position where the scene should be spawn
##
func _init(scene: PackedScene, startPos: Vector3, spawnPos: float):
	self.m_Scene    = scene
	self.m_StartPos = startPos
	self.m_SpawnPos = spawnPos

###
# Gets preloaded scene
#@return preloaded scene
##
func get_scene():
	return self.m_Scene

###
# Gets start position on parent scene
#@return start position on parent scene
##
func get_start_pos():
	return self.m_StartPos

###
# Gets spawn position in the scrolling
#@return spawn position in the scrolling
##
func get_spawn_pos():
	return self.m_SpawnPos

###
# Sets entity as spawned
##
func set_spawned():
	self.m_Spawned = true

###
# Checks if entity was spawned
#@return true if entity was spawned, otherwise false
##
func is_spawned():
	return self.m_Spawned
