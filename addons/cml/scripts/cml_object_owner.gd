@tool
class_name CML_ObjectOwner
extends Node


func _get( property: StringName ) -> Variant:
	
	return get_object( property )


func _set( property: StringName, value: Variant ) -> bool:
	
	if not property in self:
		if value is Node:
			set_object( value )
			return true
	
	return false


func has_object( object_name: String ) -> bool:
	
	return has_node( object_name )


func get_object( object_name: String ) -> Node:
	
	if has_object( object_name ):
		return get_node( object_name )
	return null


func set_object( object: Node ) -> bool:
	
	if object.is_inside_tree() or is_instance_valid( object.get_parent() ):
		printerr( "Can't set objects which are already parented." )
		return false
	
	add_child( object, true, Node.INTERNAL_MODE_DISABLED )
	return true







func save_snapshot():
	
	var snapshot = {
		"objects": [],
	}
	
	for node in get_children( false ):
		if node.has_method( &"save_snapshot" ):
			snapshot["objects"].append( node.save_snapshot() )
	
	return snapshot



func load_snapshot( p_snapshot: Dictionary ) -> Error:
	
	var err := OK
	
	if "objects" in p_snapshot:
		for object_snapshot in p_snapshot["objects"]:
			# Unimplemented i got shit to do
			pass
	
	return err
