extends Node3D

# components
@onready var m_Player: CharacterBody3D = $"../Player"

var m_Name     = ""
var m_Time     = 0
var m_Robot    = 0
var m_RowCount = 0

const m_TabChar       = "\t"
const m_RowHeight     = 7
const m_PlatformAngle = 22.5

###
# Create the tower fundation (i.e. the underwater part)
##
func CreateTowerFundation():
	for x in range(4):
		var towerBody = preload("res://scenes/tower_body.tscn").instantiate()
		add_child(towerBody)

		var towerPosY = 0 - (m_RowHeight * x)
		towerBody.global_position = Vector3(0.0, towerPosY, 0.0)

func ParseColor(line):
	pass

func ParseDataLine(dataIndex, line):
	# first data is the tower row count
	if (dataIndex == 0):
		m_RowCount = line.to_int()
		return

	var towerBody = preload("res://scenes/tower_body.tscn").instantiate()
	add_child(towerBody)

	var towerPosY = (m_RowCount * m_RowHeight) - (m_RowHeight * dataIndex)
	towerBody.global_position = Vector3(0.0, towerPosY, 0.0)

	var index   = 0;
	var portal1 = null
	var portal2 = null

	for x in range(line.length()):
		var ch = line[x]

		match ch:
			# skip empty spaces
			m_TabChar: index  = (index + 4) - (index % 4)
			" ":       index += 1
			"|":       index += 1

			"#":
				# create a portal and attach it to the scene. NOTE the portal is always set above a
				# platform in the level files, for that reason it is located lower on the y axis
				var portal = preload("res://scenes/portal.tscn").instantiate()
				add_child(portal)

				# connect the portal opening signals to the player
				portal.can_enter_portal.connect(m_Player._on_can_enter_portal)

				var posY = (m_RowCount * m_RowHeight) - (m_RowHeight * dataIndex) - m_RowHeight + 0.5
				portal.global_position = Vector3(0.0, posY, 0.0)

				var rotY = deg_to_rad(m_PlatformAngle * index)
				portal.global_rotation = Vector3(0.0, rotY, 0.0)

				# keep portals in order to associate them
				if (portal1 == null):
					portal1 = portal
				elif (portal2 == null):
					portal2 = portal
				else:
					print("Loading level - ERROR - too many portals on the same row")

				index += 1

			"^":
				# create an elevator and attach it to the scene. NOTE the elevator is always set above
				# a platform in the level files, for that reason it is located lower on the y axis
				var elevator = preload("res://scenes/elevator.tscn").instantiate()
				add_child(elevator)

				# connect the portal opening signals to the player
				#portal.can_enter_portal.connect(m_Player._on_can_enter_portal)

				var posY = (m_RowCount * m_RowHeight) - (m_RowHeight * dataIndex) - m_RowHeight + 1.5
				elevator.global_position = Vector3(0.0, posY, 0.0)

				var rotY = deg_to_rad(m_PlatformAngle * index)
				elevator.global_rotation = Vector3(0.0, rotY, 0.0)

				index += 1

			"-":
				# create a platform and attach it to the scene
				var platform = preload("res://scenes/platform.tscn").instantiate()
				add_child(platform)

				var posY = (m_RowCount * m_RowHeight) - (m_RowHeight * dataIndex)
				platform.global_position = Vector3(0.0, posY, 0.0)

				var rotY = deg_to_rad(m_PlatformAngle * index)
				platform.global_rotation = Vector3(0.0, rotY, 0.0)

				index += 1

			"L":
				# create a lamp and attach it to the scene
				var lamp = preload("res://scenes/wall_lamp.tscn").instantiate()
				add_child(lamp)

				var posY = (m_RowCount * m_RowHeight) - (m_RowHeight * dataIndex)
				lamp.global_position = Vector3(0.0, posY, 0.0)

				var rotY = deg_to_rad(m_PlatformAngle * index)
				lamp.global_rotation = Vector3(0.0, rotY, 0.0)

				index += 1

			_:
				# default, unknown char, log and skip
				print("Loading level - unknown char found - " + ch)
				index += 1

	# bind portals together
	if (portal1 and portal2):
		portal1.m_ConnectedPortal = portal2
		portal2.m_ConnectedPortal = portal1
	elif (portal1 or portal2):
		print("Loading level - ERROR - only one portal on the row - cannot bind")

func ParseDemoLine(demoIndex, line):
	var value = line.to_int()
	#print("Demo value:", value)

###
# Loads a tower level
#@param fileName - tower level file name
##
func LoadLevel(fileName):
	# create the tower fundation (the underwater part)
	CreateTowerFundation()

	# open the tower level file
	var file = FileAccess.open(fileName, FileAccess.READ)

	var section   = ""
	var dataIndex = 0
	var demoIndex = 0

	# iterate through file lines until the file end is reached
	while not file.eof_reached():
		# get next line
		var line = file.get_line().trim_suffix("\r")

		# detect section headers
		if line.begins_with("[") and line.ends_with("]"):
			section = line
			continue

		# process the current section
		match section:
			"[name]":  m_Name = line
			"[color]": ParseColor(line)
			"[time]":  m_Time = line.to_int()
			"[robot]": m_Robot = line.to_int()
			
			"[data]":
				ParseDataLine(dataIndex, line)
				dataIndex += 1

			"[demo]":
				ParseDemoLine(demoIndex, line)
				demoIndex += 1

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	LoadLevel("res://levels/tower1.txt")

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _process(delta):
	pass
