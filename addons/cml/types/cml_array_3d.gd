@tool
#@icon( "res://addons/editor_icons/godot/editor/icons/BoxShape3D.svg" )
class_name CML_Array3D
extends Resource


var begin = Vector3i( 0, 0, 0 )
var size = Vector3i( 0, 0, 0 )
var end = Vector3i( 0, 0, 0 )

## Map of cell coordinates to static cell resources.
var items = {}



## Virtual
func construct_item() -> Variant:
	
	return null


## Virtual
func destroy_item( p_item: Variant ) -> void:
	
	pass



func _get_property_list():
	
	const properties = [
		{
			"type": TYPE_DICTIONARY,
			"name": "items",
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"usage": PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_NO_EDITOR | PROPERTY_USAGE_STORAGE,
		},
		{
			"type": TYPE_VECTOR3I,
			"name": "begin",
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"usage": PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_NO_EDITOR | PROPERTY_USAGE_STORAGE,
		},
		{
			"type": TYPE_VECTOR3I,
			"name": "size",
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"usage": PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_NO_EDITOR | PROPERTY_USAGE_STORAGE,
		},
		{
			"type": TYPE_VECTOR3I,
			"name": "end",
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"usage": PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_NO_EDITOR, # Storage bit is omitted since storing the end is redundant
		}
	]
	
	return properties



func resize( p_begin, p_end ):
	
	var old_iteration_ranges = get_iteration_ranges()
	var new_iteration_ranges = get_iteration_ranges( p_begin, p_end )
	
	for cell in items.keys():
		
		if not cell_is_in_range( cell, p_begin, p_end ):
			var item = get_item( cell )
			destroy_item( item )
			items.erase( cell )
	
	for x in new_iteration_ranges.x:
		for y in new_iteration_ranges.y:
			for z in new_iteration_ranges.z:
				
				var cell = Vector3i( x, y, z )
				
				if not has_at( cell ):
					items[cell] = construct_item()
	
	begin = p_begin
	size = p_end - p_begin
	end = p_end


## Expands/shrinks the array to fit whatever is present within.
func resize_to_fit_contents():
	
	var min_cell = Vector3i.ZERO
	var max_cell = Vector3i.ZERO
	
	# Don't resize if not necessary
	for cell in items:
		if cell.x < min_cell.x \
		or cell.y < min_cell.y \
		or cell.z < min_cell.z:
			min_cell = cell
			continue
		
		if cell.x > max_cell.x \
		or cell.y > max_cell.y \
		or cell.z > max_cell.z:
			max_cell = cell
			continue
	
	max_cell += Vector3i.ONE
	
	if min_cell != begin or max_cell != end:
		resize( min_cell, max_cell )


func get_iteration_ranges( p_begin = begin, p_end = end ):
	
	return {
		"x": range( p_begin.x, p_end.x ),
		"y": range( p_begin.y, p_end.y ),
		"z": range( p_begin.z, p_end.z ),
	}



func has_at( p_cell: Vector3i ) -> bool:
	
	return items.has( p_cell )


func erase_at( p_cell: Vector3i ) -> void:
	
	return items.erase( p_cell )


func get_item( at_cell: Vector3i ) -> Variant:
	
	if items.has( at_cell ):
		return items[at_cell]
	
	return null


func set_item( at_cell: Vector3i, p_item: Variant ) -> void:
	
	items[at_cell] = p_item


func cell_is_in_range( p_cell, p_begin = begin, p_end = end ):
	
	return \
		p_cell.x >= p_begin.x and \
		p_cell.x < p_end.x and \
		p_cell.y >= p_begin.y and \
		p_cell.y < p_end.y and \
		p_cell.z >= p_begin.z and \
		p_cell.z < p_end.z
