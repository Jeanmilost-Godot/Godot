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

	var index = 0;

	for x in range(line.length()):
		var ch = line[x]

		match ch:
			# skip empty spaces
			m_TabChar: index += 4
			" ":       index += 1

			"-":
				# create a platform and attach it to the scene
				var platform = preload("res://scenes/tower_platform.tscn").instantiate()
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

func ParseDemoLine(demoIndex, line):
	var value = line.to_int()
	#print("Demo value:", value)

###
# Loads a tower level
#@param fileName - tower level file name
##
func LoadLevel(fileName):
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
