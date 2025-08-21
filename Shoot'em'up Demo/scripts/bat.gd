extends CharacterBody3D

# children instances
@onready var m_Bat: Node3D = $Model

# variables
var path: Path

# signals
signal increment_score()

###
# Explodes the enemy
##
func explode():
	# hide the bat model
	m_Bat.hide();

	# create an explosion and attach it to the scene
	var explosion = preload("res://scenes/explosion.tscn").instantiate()
	get_tree().current_scene.add_child(explosion)

	explosion.global_position = global_position
	explosion.fire()

	# notify that the score should be incremented
	increment_score.emit()

	# delete the bat
	queue_free()

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	CollisionManager.do_delete.connect(_on_collision_manager_do_delete)

	path = Path.new()
	path.end_reached.connect(_on_path_end_reached)
	path.add_linear_path(global_position, Vector3(global_position.x, global_position.y - 40.0, global_position.z), 3.0, 0.0)

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _physics_process(delta):
	var velocity = path.get_pos(delta)

	#REM print(velocity.y)
	
	# move the bat and check for collision
	var collision = move_and_collide(velocity * delta)

	# found a collision?
	if collision:
		var collider = collision.get_collider()

		# collided something in the scene?
		if collider is CharacterBody3D or collider is StaticBody3D:
			# register collision in manager
			CollisionManager.register_collision(self, collider)

###
# Called when the bat goes out of the screen
##
func _on_visibility_notifier_screen_exited():
	# delete the bat
	queue_free()

###
# Called when the collision manager notifies that the item should be deleted
#@param obj1 - first object involved in the collision, may be either the item itself or its collider
#@param obj1 - second object involved in the collision, may be either the item itself or its collider
##
func _on_collision_manager_do_delete(obj1, obj2):
	if (obj1 != self and obj2 != self):
		return

	explode()

func _on_path_end_reached():
	pass
