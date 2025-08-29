###
# Game entities
#@author Jean-Milost Reymond
##
class_name Entities

extends RefCounted

# variables
var m_Entities: Array[Entity] = []

###
# Adds an entity to the list
#@param scene - preloaded scene to spawn
#@param startPos - scene start position in the parent scene
#@param spawnPos - position where the scene should be spawn
##
func add_entity(scene: PackedScene, startPos: Vector3, spawnPos: float):
	var entity = Entity.new(scene, startPos, spawnPos)
	m_Entities.append(entity)

func get_entity(index):
	if index >= m_Entities.size():
		return null

	return m_Entities[index]

###
# Constructor
##
func _init():
	load_patterns()

###
# Loads the entities patterns
##
func load_patterns():
	add_entity(preload("res://scenes/bat_pattern_1.tscn"), Vector3(-40,  40, -40), -20)
	add_entity(preload("res://scenes/bat_pattern_1.tscn"), Vector3(-40,  50, -50), -30)
	add_entity(preload("res://scenes/bat_pattern_1.tscn"), Vector3(-40,  60, -60), -40)
	add_entity(preload("res://scenes/bat_pattern_1.tscn"), Vector3(-40,  70, -70), -50)

	add_entity(preload("res://scenes/bat_pattern_1.tscn"), Vector3(-40,  45, -80), -60)
	add_entity(preload("res://scenes/bat_pattern_1.tscn"), Vector3(-40,  55, -90), -70)
	add_entity(preload("res://scenes/bat_pattern_1.tscn"), Vector3(-40,  65, -100), -80)

###
# Gets entities count
#@return entities count
##
func get_count():
	return m_Entities.size()

###
# Gets item preloaded scene
#@param index - item index
#@return preloaded scene
##
func get_scene(index):
	if index >= m_Entities.size():
		return null

	return get_entity(index).get_scene()

###
# Gets start position on parent scene
#@param index - item index
#@return start position on parent scene
##
func get_start_pos(index):
	if index >= m_Entities.size():
		return Vector3()

	return get_entity(index).get_start_pos()

###
# Gets spawn position in the scrolling
#@param index - item index
#@return spawn position in the scrolling
##
func get_spawn_pos(index):
	if index >= m_Entities.size():
		return 0.0

	return get_entity(index).get_spawn_pos()

###
# Sets entity as spawned
#@param index - item index
##
func set_spawned(index):
	if index >= m_Entities.size():
		return

	get_entity(index).set_spawned()

###
# Checks if entity was spawned
#@param index - item index
#@return true if entity was spawned, otherwise false
##
func is_spawned(index):
	if index >= m_Entities.size():
		return false

	return get_entity(index).is_spawned()
