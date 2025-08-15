###
# Path an entity may follow
#@author Jean-Milost Reymond
##
class_name Path

extends RefCounted

###
# Path types enumeration
##
enum E_TYPE {LINE, QUADRATIC_BEZIER, CUBIC_BEZIER, CIRCLE}

###
# Rotation direction enumeration
##
enum E_ROT_DIR {CW, CCW}

###
# Basic path command
##
class BasicPathCmd:
	var m_Type:  E_TYPE
	var m_Time:  float = 0.0
	var m_Accel: float = 0.0

	###
	# Constructor
	#@param type - path type
	#@param time - total time to execute the path command
	#@param accel - acceleration to apply to the path
	##
	func _init(type: E_TYPE, time: float, accel: float):
		self.m_Type  = type
		self.m_Time  = time
		self.m_Accel = accel

	###
	# Sets start position
	#@param pos - start position
	##
	func set_start_pos(pos: Vector3):
		pass

	###
	# Gets current position
	#@param progress - current progress, in percent, between 0.0 and 1.0
	#@return current position
	##
	func get_pos(progress):
		return Vector3()

###
# Linear path command
##
class LinearPathCmd extends BasicPathCmd:
	var m_Start: Vector3
	var m_End:   Vector3

	###
	# Constructor
	#@param type - path type
	#@param start - path start position
	#@param end - path end position
	#@param time - total time to execute the path command
	#@param accel - acceleration to apply to the path
	##
	func _init(type: E_TYPE, start: Vector3, end: Vector3, time: float, accel: float):
		super(type, time, accel)

		self.m_Start = start
		self.m_End   = end

	###
	# Sets start position
	#@param pos - start position
	##
	func set_start_pos(pos: Vector3):
		self.m_Start = pos

	###
	# Gets current position
	#@param progress - current progress, in percent, between 0.0 and 1.0
	#@return current position
	##
	func get_pos(progress):
		var pos = clampf(progress, 0.0, 1.0)

		match self.m_Type:
			E_TYPE.LINE: return m_Start + ((m_End - m_Start) * pos)
			_:           return Vector3()

###
# Bezier path command
##
class BezierPathCmd extends BasicPathCmd:
	var m_Start: Vector3
	var m_End:   Vector3
	var m_Ctrl1: Vector3
	var m_Ctrl2: Vector3

	###
	# Constructor
	#@param type - path type
	#@param start - path start position
	#@param end - path end position
	#@param ctrl1 - first control point
	#@param ctrl2 - second control point, can be empty if unused
	#@param time - total time to execute the path command
	#@param accel - acceleration to apply to the path
	##
	func _init(type: E_TYPE, start: Vector3, end: Vector3, ctrl1: Vector3, ctrl2: Vector3, time: float, accel: float):
		super(type, time, accel)

		self.m_Start = start
		self.m_End   = end
		self.m_Ctrl1 = ctrl1
		self.m_Ctrl2 = ctrl2

	###
	# Sets start position
	#@param pos - start position
	##
	func set_start_pos(pos: Vector3):
		self.m_Start = pos

	###
	# Gets current position
	#@param progress - current progress, in percent, between 0.0 and 1.0
	#@return current position
	##
	func get_pos(progress):
		var pos = clampf(progress, 0.0, 1.0)

		match self.g_Type:
			E_TYPE.QUADRATIC_BEZIER: return BezierCurve.get_quadratic_bezier_point(self.m_Start, self.m_End, self.m_Ctrl1,               pos)
			E_TYPE.CUBIC_BEZIER:     return BezierCurve.get_cubic_bezier_point    (self.m_Start, self.m_End, self.m_Ctrl1, self.m_Ctrl2, pos)
			_:                       return Vector3()

###
# Circle path command
##
class CirclePathCmd extends BasicPathCmd:
	var m_Start:  Vector3
	var m_Center: Vector3
	var m_Radius: Vector2
	var m_Angle:  float = (PI * 2.0)
	var m_2PI:    float = (PI * 2.0)
	var m_RotDir: E_ROT_DIR

	###
	# Constructor
	#@param type - path type
	#@param center - circle center, relative to start position
	#@param radius - circle radius
	#@param angle - angle defining the path to be traveled around the circle, in radians
	#@param rotDir - rotation direction
	#@param time - total time to execute the path command
	#@param accel - acceleration to apply to the path
	##
	func _init(type: E_TYPE, center: Vector3, radius: Vector2, angle: float, rotDir: E_ROT_DIR, time: float, accel: float):
		super(type, time, accel)

		self.m_Center = center
		self.m_Radius = radius
		self.m_Angle  = angle
		self.m_RotDir = rotDir

	###
	# Sets start position
	#@param pos - start position
	##
	func set_start_pos(pos: Vector3):
		self.m_Start = pos

	###
	# Gets current position
	#@param progress - current progress, in percent, between 0.0 and 1.0
	#@return current position
	##
	func get_pos(progress):
		var pos = clampf(progress, 0.0, 1.0)

		match self.m_Type:
			E_TYPE.CIRCLE:
				# calculate circle center in relation to the current position
				var absoluteCenter = Vector3(self.m_Start.x + self.m_Center.x, self.m_Start.y + self.m_Center.y, self.m_Start.z)

				var angle = pos * self.m_2PI

				# calculate the rotation angle
				match self.g_RotDir:
					E_ROT_DIR.CW:  angle =                 (angle * self.m_Angle) / (self.m_2PI)
					E_ROT_DIR.CCW: angle = (self.m_2PI) - ((angle * self.m_Angle) / (self.m_2PI))
					_:             return Vector3()

				var result: Vector3

				# calculate the current position around the circle
				result.x = self.m_Start.x + (self.m_Radius.x * cos(angle))
				result.y = self.m_Start.y + (self.m_Radius.y * sin(angle))
				result.z = self.m_Start.z

				return result

			_:
				return Vector3()

# variables
var m_PathCmds: Array[BasicPathCmd] = []
var m_CmdIndex                      = 0
var m_ElapsedTime                   = 0.0

###
# Adds a linear command to the path
#@param start - path start position
#@param end - path end position
#@param time - total time to execute the path command
#@param accel - acceleration to apply to the path
##
func add_linear_path(start: Vector3, end: Vector3, time: float, accel: float):
	var pathCmd = LinearPathCmd.new(E_TYPE.LINE, start, end, time, accel)
	m_PathCmds.append(pathCmd)

###
# Adds a Bezier command to the path
#@param type - path type
#@param start - path start position
#@param end - path end position
#@param ctrl1 - first control point, can be empty if unused
#@param ctrl2 - second control point, can be empty if unused
#@param time - total time to execute the path command
#@param accel - acceleration to apply to the path
##
func add_bezier_path(type: E_TYPE, start: Vector3, end: Vector3, ctrl1: Vector3, ctrl2: Vector3, time: float, accel: float):
	var pathCmd = BezierPathCmd.new(type, start, end, ctrl1, ctrl2, time, accel)
	m_PathCmds.append(pathCmd)

###
# Adds a circle command to the path
#@param type - path type
#@param center - circle center, relative to start position
#@param radius - circle radius
#@param angle - angle defining the path to be traveled around the circle
#@param rotDir - rotation direction
#@param time - total time to execute the path command
#@param accel - acceleration to apply to the path
##
func add_circle_path(center: Vector3, radius: Vector2, angle: float, rotDir: E_ROT_DIR, time: float, accel: float):
	var pathCmd = CirclePathCmd.new(E_TYPE.CIRCLE, center, radius, angle, rotDir, time, accel)
	m_PathCmds.append(pathCmd)

func get_pos(elapsedTime):
	m_ElapsedTime += elapsedTime

	var pathCmd = m_PathCmds[m_CmdIndex]
	
