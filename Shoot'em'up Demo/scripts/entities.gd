class_name Entities

extends RefCounted

# variables
var m_Entities: Array[Entity] = []

func add_entity():
	var entity = Entity.new()
	m_Entities.append(entity)

func get_entity(index):
	if index >= m_Entities.size():
		return null

	return m_Entities[index]

func _init():
	add_entity()
