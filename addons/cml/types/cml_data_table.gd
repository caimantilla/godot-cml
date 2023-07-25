@tool
class_name CML_DataTable
extends Resource


@export var expose_record_list_in_editor: bool = true:
	set( value ):
		expose_record_list_in_editor = value
		notify_property_list_changed()

var record_list: Array = []: set = set_record_list

var record_map: Dictionary = {}



func _get_property_list() -> Array [Dictionary]:
	
	var IF_EXPOSED: Array [Dictionary] = [
		{
			"type": TYPE_ARRAY,
			"name": "record_list",
			"hint": PROPERTY_HINT_TYPE_STRING,
			"hint_string": "%s/%s:%s" % [ TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE, "CML_DataRecord" ],
			"usage": PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR,
		}
	]
	
	const IF_NOT_EXPOSED: Array [Dictionary] = [
#		{
#			"type": TYPE_ARRAY,
#			"name": "record_list",
#			"hint": PROPERTY_HINT_NONE,
#			"hint_string": "",
#			"usage": PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_NO_EDITOR,
#		}
	]
	
	if expose_record_list_in_editor:
		return IF_EXPOSED
	else:
		return IF_NOT_EXPOSED



func _init() -> void:
	
	reload()


## Virtual
func reload() -> void:
	
	pass



func validate_id( id: Variant ) -> int:
	
	var id_type: int = typeof( id )
	
	match id_type:
		
		TYPE_FLOAT:
			id = roundi( id )
		
		TYPE_STRING, TYPE_STRING_NAME:
			if record_map.has( id ):
				id = record_map[id] as int
	
	id_type = typeof( id )
	if id_type != TYPE_INT:
		return -1
	if id < 0 or id >= record_list.size():
		return -1
	
	return id


func has_record( id: Variant ) -> bool:
	
	id = validate_id( id )
	
	return id != -1



func get_record( id: Variant ) -> CML_DataRecord:
	
	id = validate_id( id )
	
	if id == -1:
		return null
	
	return record_list[id] as CML_DataRecord


func get_records() -> Array [CML_DataRecord]:
	
	return record_list


func set_record( p_record: CML_DataRecord ) -> bool:
	
	var id = p_record.get_id()
	
	if id.is_empty():
		return false
	
	if has_record( id ):
		id = validate_id( id )
		record_list[id] = p_record
	
	else:
		record_map[id] = record_list.size()
		record_list.append( p_record )
	
	return true



func set_record_list( p_record_list: Array ) -> void:
	
	record_map.clear()
	
	for index in p_record_list.size():
		var record := p_record_list[index] as CML_DataRecord
		if is_instance_valid( record ):
			var id := record.get_id()
			if not id.is_empty():
				record_map[id] = index
	
	record_list = p_record_list






func get_data_paths() -> PackedStringArray:
	
	var project_setting: String = "devil_engine_core/table/" + get_table_id()
	
	if not ProjectSettings.has_setting( project_setting ) \
	or not typeof( ProjectSettings.get_setting(project_setting, null) ) == TYPE_PACKED_STRING_ARRAY:
		if Engine.is_editor_hint():
			var initial_value := PackedStringArray()
			ProjectSettings.set_setting( project_setting, initial_value )
			ProjectSettings.set_initial_value( project_setting, initial_value )
	
	var value := ProjectSettings.get_setting_with_override( project_setting ) as PackedStringArray
	
	return value


static func get_table_id() -> String:
	
	return "default_table_id"
