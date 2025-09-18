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
# Adds an entity pattern
#@param scene - preloaded scene to spawn
#@param y - starting y position in the scene
#@param startPos - start position in the scroll timeline
##
func add_pattern(scene: PackedScene, y: float, startPos: float):
	add_entity(scene, Vector3(-40,  y, startPos - 40.0),  startPos)

###
# Loads the entities patterns
##
func load_patterns():
	var startPos = -20
	add_entity(preload("res://scenes/ghast_pattern_1.tscn"), Vector3(-40,  0, startPos - 55.0),  startPos)
	return

	# pyjama sharks, layout 1
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -25, -39)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -25, -45)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -25, -57)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -25, -71)

	# pyjama sharks, layout 2
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -35, -43)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -35, -48)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -35, -52)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -35, -56)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -35, -59)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -35, -60)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -35, -67)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -35, -72)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -35, -76)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -35, -80)

	# pyjama sharks, layout 3
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -40, -40)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -40, -45)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -40, -50)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -40, -55)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -40, -57)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -40, -62)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -40, -65)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -40, -70)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -40, -75)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -40, -77)

	# pyjama sharks, layout 4
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50, -35)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -50, -39)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50, -42)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50, -44)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50, -45)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -50, -48)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50, -49)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -50, -51)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -50, -54)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50, -55)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50, -58)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50, -62)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -50, -67)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50, -71)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50, -74)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -50, -75)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50, -79)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50, -82)

	# pyjama sharks, layout 5
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -33)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55, -35)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -37)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -39)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55, -41)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -43)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -45)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -47)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55, -49)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -51)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -53)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55, -55)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -57)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55, -59)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55, -61)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -63)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -65)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -67)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -69)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -71)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55, -73)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -75)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -77)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -79)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55, -81)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -83)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55, -85)

	# seahorses, first wave
	add_pattern(preload("res://scenes/seahorse_pattern_1.tscn"), -40, -110)
	add_pattern(preload("res://scenes/seahorse_pattern_1.tscn"), -35, -125)
	add_pattern(preload("res://scenes/seahorse_pattern_1.tscn"), -45, -140)
	add_pattern(preload("res://scenes/seahorse_pattern_1.tscn"), -30, -155)
	add_pattern(preload("res://scenes/seahorse_pattern_1.tscn"), -50, -170)

	# bats, first wave
	add_pattern(preload("res://scenes/bat_pattern_1.tscn"), 40, -240)
	add_pattern(preload("res://scenes/bat_pattern_1.tscn"), 50, -245)
	add_pattern(preload("res://scenes/bat_pattern_1.tscn"), 60, -250)
	add_pattern(preload("res://scenes/bat_pattern_1.tscn"), 70, -255)
	add_pattern(preload("res://scenes/bat_pattern_1.tscn"), 45, -260)
	add_pattern(preload("res://scenes/bat_pattern_1.tscn"), 55, -265)
	add_pattern(preload("res://scenes/bat_pattern_1.tscn"), 65, -270)

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
