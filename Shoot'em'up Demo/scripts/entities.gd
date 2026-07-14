###
# Game entities
#@author Jean-Milost Reymond
##
class_name Entities

extends RefCounted

# variables
var m_Entities: Array[Entity] = []

###
# Constructor
##
func _init():
	load_patterns()

###
# Adds an entity to the list
#@param scene - preloaded scene to spawn
#@param startPos - scene start position in the parent scene
#@param spawnPos - position where the scene should be spawn
##
func add_entity(scene: PackedScene, startPos: Vector3, spawnPos: float):
	var entity = Entity.new(scene, startPos, spawnPos)
	m_Entities.append(entity)

###
# Gets an entitiy at index
#@param index - entity index to get
#@return entity, null if not found or on error
##
func get_entity(index):
	if index >= m_Entities.size():
		return null

	return m_Entities[index]

###
# Adds an entity pattern
#@param scene - preloaded scene to spawn
#@param y - starting y position in the scene
#@param startPos - start position in the scroll timeline
#@param shift - shift value on the scene z axis from the start position
##
func add_pattern(scene: PackedScene, y: float, startPos: float, shift: float = 40.0):
	add_entity(scene, Vector3(-40, y, startPos - shift),  startPos)

###
# Adds a spider pattern
#@param startPos - start position in the scroll timeline
##
func add_spider(startPos: float):
	add_entity(preload("res://scenes/spider_pattern.tscn"), Vector3(-42, 0, startPos - 65),  startPos)

###
# Loads the entities patterns
##
func load_patterns():
	# pyjama sharks, layout 1
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -25.0, -39.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -25.0, -45.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -25.0, -57.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -25.0, -71.0)

	# pyjama sharks, layout 2
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -35.0, -43.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -35.0, -48.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -35.0, -52.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -35.0, -56.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -35.0, -59.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -35.0, -60.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -35.0, -67.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -35.0, -72.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -35.0, -76.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -35.0, -80.0)

	# pyjama sharks, layout 3
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -40.0, -40.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -40.0, -45.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -40.0, -50.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -40.0, -55.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -40.0, -57.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -40.0, -62.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -40.0, -65.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -40.0, -70.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -40.0, -75.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -40.0, -77.0)

	# pyjama sharks, layout 4
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50.0, -35.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -50.0, -39.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50.0, -42.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50.0, -44.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50.0, -45.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -50.0, -48.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50.0, -49.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -50.0, -51.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -50.0, -54.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50.0, -55.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50.0, -58.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50.0, -62.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -50.0, -67.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50.0, -71.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50.0, -74.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -50.0, -75.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50.0, -79.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -50.0, -82.0)

	# pyjama sharks, layout 5
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -33.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55.0, -35.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -37.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -39.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55.0, -41.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -43.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -45.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -47.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55.0, -49.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -51.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -53.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55.0, -55.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -57.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55.0, -59.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55.0, -61.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -63.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -65.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -67.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -69.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -71.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55.0, -73.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -75.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -77.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -79.0)
	add_pattern(preload("res://scenes/nocturnus_pattern_1.tscn"),    -55.0, -81.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -83.0)
	add_pattern(preload("res://scenes/pyjama_shark_pattern_1.tscn"), -55.0, -85.0)

	# seahorses, first wave
	add_pattern(preload("res://scenes/seahorse_pattern_1.tscn"), -40.0, -150.0)
	add_pattern(preload("res://scenes/seahorse_pattern_1.tscn"), -35.0, -165.0)
	add_pattern(preload("res://scenes/seahorse_pattern_1.tscn"), -45.0, -180.0)
	add_pattern(preload("res://scenes/seahorse_pattern_1.tscn"), -30.0, -195.0)
	add_pattern(preload("res://scenes/seahorse_pattern_1.tscn"), -50.0, -210.0)

	# bats, first wave
	add_pattern(preload("res://scenes/bat_pattern_1.tscn"), 40.0, -280.0)
	add_pattern(preload("res://scenes/bat_pattern_1.tscn"), 50.0, -285.0)
	add_pattern(preload("res://scenes/bat_pattern_1.tscn"), 60.0, -290.0)
	add_pattern(preload("res://scenes/bat_pattern_1.tscn"), 70.0, -295.0)
	add_pattern(preload("res://scenes/bat_pattern_1.tscn"), 45.0, -300.0)
	add_pattern(preload("res://scenes/bat_pattern_1.tscn"), 55.0, -305.0)
	add_pattern(preload("res://scenes/bat_pattern_1.tscn"), 65.0, -310.0)

	# sculpted heads, first wave
	var headStartPos = -350.0
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  0.0,  headStartPos - 65.0),   headStartPos)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  10.0, headStartPos - 70.0),   headStartPos - 5)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  20.0, headStartPos - 75.0),   headStartPos - 10)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  30.0, headStartPos - 80.0),   headStartPos - 15)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  0.0,  headStartPos - 85.0),   headStartPos - 20)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  30.0, headStartPos - 85.0),   headStartPos - 20)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  10.0, headStartPos - 90.0),   headStartPos - 25)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  20.0, headStartPos - 90.0),   headStartPos - 25)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  0.0,  headStartPos - 95.0),   headStartPos - 30)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  20.0, headStartPos - 95.0),   headStartPos - 30)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  10.0, headStartPos - 100.0),  headStartPos - 35)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  30.0, headStartPos - 100.0),  headStartPos - 35)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  10.0, headStartPos - 105.0),  headStartPos - 40)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  30.0, headStartPos - 105.0),  headStartPos - 40)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  0.0,  headStartPos - 110.0),  headStartPos - 45)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  20.0, headStartPos - 110.0),  headStartPos - 45)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  0.0,  headStartPos - 115.0),  headStartPos - 50)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  10.0, headStartPos - 115.0),  headStartPos - 50)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  20.0, headStartPos - 115.0),  headStartPos - 50)
	add_entity(preload("res://scenes/sculpted_head_pattern_1.tscn"), Vector3(-40.0,  30.0, headStartPos - 115.0),  headStartPos - 50)

	# ghast (in-level boss)
	add_pattern(preload("res://scenes/ghast_pattern_1.tscn"), 0.0, -440.0, 65.0)

	# spiders
	add_spider(-600.0)
	add_spider(-650.0)
	add_spider(-700.0)
	add_spider(-750.0)

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
