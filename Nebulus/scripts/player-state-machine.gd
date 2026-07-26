###
# Player state machine
#@author Jean-Milost Reymond
##
class_name PlayerStateMachine

extends RefCounted

# states
enum IEState {S_Idle, S_Crossing_Portal, S_Using_Elevator, S_Falling}

# sub-states
enum IESubState {S_Idle, S_Turning}

# variables
var m_State:    IEState
var m_SubState: IESubState

###
# Constructor
##
func _init():
	self.m_State    = IEState.S_Idle
	self.m_SubState = IESubState.S_Idle

###
# Gets current machine state
#@return current machine state
##
func get_state() -> IEState:
	return self.m_State

###
# Set scurrent machine state
#@param state - current machine state
##
func set_state(state: IEState):
	self.m_State = state

###
# Gets current machine sub-state
#@return current machine sub-state
##
func get_substate() -> IESubState:
	return self.m_SubState

###
# Set scurrent machine state
#@param state - current machine state
##
func set_substate(state: IESubState):
	self.m_SubState = state
