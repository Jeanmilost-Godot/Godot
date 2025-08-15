###
# Game entity, may be an enemy, a bullet, ...
#@author Jean-Milost Reymond
##
class_name Entity

extends RefCounted

# variables
var m_Pos:      Vector3
var m_SwawnPos: float = 0.0
var m_Spawned:  bool  = false

func _init():
	pass

func set_spawned():
	self.m_Spawned = true

func is_spawned():
	return m_Spawned
