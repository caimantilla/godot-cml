@tool
class_name CML_AnimationState
extends Node


var Direction = {}


signal looped()
signal finished()

var _is_active: bool = false


func _init():
	
	set_direction_enum( _get_direction_enum() )


func trigger():
	
	_trigger()
	_is_active = true

func stop():
	
	_stop()
	_is_active = false


func is_active() -> bool:
	
	return _is_active


func set_animation_speed( p_speed_multiplier: float ):
	
	pass


func set_direction( p_direction ):
	
	pass


## Virtual
func _trigger():
	
	pass


## Virtual
func _stop():
	
	pass


func set_direction_enum( p_direction_enum ):
	
	Direction = p_direction_enum


func _get_direction_enum():
	
	return {}
