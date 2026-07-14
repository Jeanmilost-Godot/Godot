extends CharacterBody3D

# children instances
@onready var m_Root:   Node3D       = $"../../.."
@onready var m_Spider: Node3D       = $Model
@onready var m_Thread: StaticBody3D = $Thread

# variables
var m_HitCount = 0

# signals
signal increment_score()

###
# Explodes the spider
##
func explode():
	# hide the spider model
	m_Spider.hide();

	# create an explosion and attach it to the scene
	var explosion = preload("res://scenes/explosion.tscn").instantiate()
	get_tree().current_scene.add_child(explosion)

	explosion.global_position = global_position
	explosion.fire()

	# notify that the score should be incremented
	increment_score.emit()

	# delete the spider
	m_Root.queue_free()

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	# connect the child thread scene signals
	m_Thread.do_explode.connect(explode)
	m_Thread.do_increment_score.connect(_on_increment_score)

	# connect the collision manager signals
	CollisionManager.do_delete.connect(_on_collision_manager_do_delete)

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _physics_process(delta):
	var velocity = Vector3()

	# check the spider collisions. Don't move it because the spider is already moved by path
	var collision = move_and_collide(velocity * delta)

	# found a collision?
	if collision:
		var collider = collision.get_collider()

		# collided something in the scene?
		if collider is CharacterBody3D or collider is StaticBody3D:
			# register collision in manager
			CollisionManager.register_collision(self, collider)

###
# Called when the spider goes out of the screen
##
func _on_visibility_notifier_screen_exited():
	# delete the spider
	m_Root.queue_free()

###
# Called when the collision manager notifies that the item should be deleted
#@param obj1 - first object involved in the collision, may be either the item itself or its collider
#@param obj1 - second object involved in the collision, may be either the item itself or its collider
##
func _on_collision_manager_do_delete(obj1, obj2):
	if (obj1 != self and obj2 != self):
		return

	if (obj1.name.contains("SeagullProjectile") || obj2.name.contains("SeagullProjectile")):
		# only explode after 25 hits
		if (m_HitCount >= 25):
			explode()

		m_HitCount += 1

		# notify that the score should be incremented
		increment_score.emit()
	else:
		explode()

###
# Called when the score should be incremented from the thread child scene
##
func _on_increment_score():
	increment_score.emit()
