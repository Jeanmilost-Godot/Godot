###
# Player state machine
#@author Jean-Milost Reymond
##
class_name PlayerStateMachine

extends RefCounted

# states
enum IEState {S_Idle, S_Turning, S_Crossing_Portal}

# variables
var m_State: IEState

###
# Constructor
##
func _init():
	self.m_State = IEState.S_Idle

###
# Gets current machine state
#@return current machine state
##
func get_state():
	return self.m_State

###
# Set scurrent machine state
#@param state - current machine state
##
func set_state(state: IEState):
	self.m_State = state
