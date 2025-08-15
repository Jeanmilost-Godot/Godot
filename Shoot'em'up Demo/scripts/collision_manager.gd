###
# Collision manager, allows 2 object to receive a collision notification simultaneously when hits
#@note This class is a singleton, autoloaded from Project -> Project Settings... -> Autoload tab
#@author Jean-Milost Reymond
##
extends Node

# variables
var m_PendingCollisions = []

# signals
signal do_delete(obj1, obj2)

###
# Register a collision
#@param item - item hit
#@param collider - item collider
##
func register_collision(item, collider):
	# create a collision pair and sort it
	var collisionPair = [item, collider]
	collisionPair.sort_custom(func(a, b): return a.get_instance_id() < b.get_instance_id())

	# is collision already registered?
	if collisionPair not in m_PendingCollisions:
		# add collision to the list
		m_PendingCollisions.append(collisionPair)

		# process deletions at the end of the frame
		if not get_tree().process_frame.is_connected(process_collisions):
			get_tree().process_frame.connect(process_collisions, CONNECT_ONE_SHOT)

###
# Process the registered collisions
##
func process_collisions():
	# iterate through registered collision pairs
	for pair in m_PendingCollisions:
		# signal the deletion to the item, with collision information
		if is_instance_valid(pair[0]) and is_instance_valid(pair[1]):
			do_delete.emit(pair[0], pair[1])

	# remove the already processed items
	m_PendingCollisions.clear()
