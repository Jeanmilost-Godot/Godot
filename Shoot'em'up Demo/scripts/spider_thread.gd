extends StaticBody3D

# children instances
@onready var m_Root:   Node3D = $"../../.."
@onready var m_Thread: Node3D = $Model

# variables
var m_HitCount = 0

# signals
signal do_explode()
signal do_increment_score()

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	CollisionManager.do_delete.connect(_on_collision_manager_do_delete)

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _physics_process(delta):
	var velocity = Vector3()

	# move the projectile and check for collision
	var collision = move_and_collide(velocity * delta)

	# found a collision?
	if collision:
		var collider = collision.get_collider()

		# collided something in the scene?
		if collider is CharacterBody3D or collider is StaticBody3D:
			# register collision in manager
			CollisionManager.register_collision(self, collider)

###
# Called when the collision manager notifies that the item should be deleted
#@param obj1 - first object involved in the collision, may be either the item itself or its collider
#@param obj1 - second object involved in the collision, may be either the item itself or its collider
##
func _on_collision_manager_do_delete(obj1, obj2):
	if (obj1 != self and obj2 != self):
		return

	if (obj1.name.contains("SeagullProjectile") || obj2.name.contains("SeagullProjectile")):
		# only explode after 30 hits
		if (m_HitCount >= 30):
			do_explode.emit()

		m_HitCount += 1

		# notify that the score should be incremented (on the paremt)
		do_increment_score.emit()
	else:
		do_explode.emit()
