@tool
class_name CML_ObjectComponentHandler
extends RefCounted


var _root_object_ref: WeakRef = null
var _implicit_components: Array [Object] = []
var _recursive: bool = false
var _include_internal: bool = false

var _components: Array [Object] = []
var _property_map: Dictionary = {}
var _property_list: Array [Dictionary] = []
#var _signal_list: Array [Dictionary] = []




func _init( p_root_object: WeakRef = null ) -> void:
	
	assert( is_instance_valid(p_root_object), "Root object must be valid." )
	_root_object_ref = p_root_object




func components_get_property_list() -> Array [Dictionary]:
	
	return _property_list


func components_has_property( property: StringName ) -> bool:
	
	var component = _property_map.get( property, null )
	if is_instance_valid( component ):
		if property in component:
			return true
	return false


func components_set_property( property: StringName, value ) -> bool:
	
	var component = _property_map.get( property, null )
	if is_instance_valid( component ):
		component.set( property, value )
		return true
	return false


func components_get_property( property: StringName ) -> Variant:
	
	var component = _property_map.get( property, null )
	if is_instance_valid( component ):
		return component.get( property )
	return null



func add_implicit_component( p_component: Object ) -> void:
	
	_implicit_components.append( p_component )


## If enabled and the root object is a node,
## the entire tree from that point will be scanned instead of just direct children.
## This is not recommended in most cases.
func set_recursive( enabled: bool = false ) -> void:
	
	_recursive = enabled

## If enabled and the root object is a node,
## internal nodes are included when looking for components.
func set_include_internal( enabled: bool = false ) -> void:
	
	_include_internal = enabled


func clear_components() -> void:
	
	_property_map.clear()
	_components.clear()
	_implicit_components.clear()


func refresh_components() -> void:
	
	_property_map.clear()
	_property_list.clear()
	_components = _implicit_components.duplicate( false )
	
	
	var _root_object = _root_object_ref.get_ref()
	
	if _root_object is Node:
		var nodes: Array [Node] = _root_object.get_children( _include_internal )
		for node in nodes:
			# This is the method used for components!! KNOW IT WELL!!!!!
			if node.has_method( &"get_property_keys_as_component" ):
				_components.append( node )
	
	
	for component in _components:
		
		if not is_instance_valid( component ):
			continue
		
		var component_property_keys = component.get_property_keys_as_component()
		
		var signal_list = component.get_signal_list()
		var method_list = component.get_method_list()
		var property_list = component.get_property_list()
		
		for property in signal_list:
			_add_property_to_map_if_compatible( property, component, component_property_keys )
		
		for property in method_list:
			_add_property_to_map_if_compatible( property, component, component_property_keys )
		
		for property in property_list:
			if _add_property_to_map_if_compatible( property, component, component_property_keys ):
				# For exporting and shit
				if property["usage"] & PROPERTY_USAGE_EDITOR:
					_property_list.append( property )


func _add_property_to_map_if_compatible( property, target_component, component_property_keys ) -> bool:
	
	if property["name"] in component_property_keys:
		_property_map[property["name"]] = target_component
		return true
	return false
