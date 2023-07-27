@tool
class_name CML_AnimationController
extends Node


var Direction


@export var idle_state_name: StringName = &""


var states: Array [CML_AnimationState] = []
var current_state: CML_AnimationState = null


func _init():
	
	Direction = _get_direction_enum()
	add_to_group( &"CML_ANIMATION_CONTROLLER", false )


func _notification( what ):
	
	match what:
		
#		NOTIFICATION_ENTER_TREE:
#			child_entered_tree.connect( _append_state )
#			_refresh_states()
		
		NOTIFICATION_READY:
#			if child_entered_tree.is_connected( _append_state ):
#				child_entered_tree.disconnect( _append_state )
			_refresh_states()
		
		NOTIFICATION_CHILD_ORDER_CHANGED:
			if is_node_ready():
				_refresh_states()


func _get_direction_enum() -> Dictionary:
	
	return {}


func get_state_names():
	
	var names = []
	
	for state in states:
		names.append( state.name )
	
	return names


func get_current_state_name():
	
	if current_state:
		return current_state.name
	
	return &""


func update( state_name: StringName = idle_state_name ) -> CML_AnimationState:
	
	if state_name.is_empty():
		
		if current_state:
			current_state.stop()
		
		current_state = null
		
		return null
	
	for state in states:
		if state_name == state.name:
			
			if current_state and current_state != state:
				current_state.stop()
			
			current_state = state
			current_state.trigger()
			
			break
	
	return current_state


func set_direction( p_direction ):
	
	for state in states:
		state.set_direction( p_direction )


func set_animation_speed( p_animation_speed ):
	
	for state in states:
		state.set_animation_speed( p_animation_speed )




func _refresh_states():
	
	states.clear()
	
	for child in get_children( false ):
		_append_state( child )


func _append_state( p_state ) -> void:
	
	if p_state is CML_AnimationState:
		states.append( p_state )
