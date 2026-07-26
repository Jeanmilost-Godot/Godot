###
# Player state machine
#@author Jean-Milost Reymond
##
class_name PlayerStateMachine

extends RefCounted

# actions
enum IEAction {A_None, A_Crossing_Portal, A_Using_Elevator}

# sub-states
enum IEState {S_Idle, S_Turning, S_Falling}

# variables
var m_Action: IEAction
var m_State:  IEState

###
# Constructor
##
func _init():
	self.m_Action = IEAction.A_None
	self.m_State  = IEState.S_Idle

###
# Gets current action
#@return current action
##
func get_action() -> IEAction:
	return self.m_Action

###
# Sets scurrent action
#@param action - current action
##
func set_action(action: IEAction):
	self.m_Action = action

###
# Gets current state
#@return current state
##
func get_state() -> IEState:
	return self.m_State

###
# Sets scurrent state
#@param state - current state
##
func set_state(state: IEState):
	self.m_State = state
