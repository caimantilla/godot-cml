@tool
class_name CML_DataRecord
extends Resource


func set_id( p_id: String ) -> void:
	
	resource_name = p_id


func get_id() -> String:
	
	if resource_name.is_empty():
		return _get_filename()
	return resource_name


func save_snapshot() -> Dictionary:
	
	var snapshot: Dictionary = {}
	
	snapshot["resource_name"] = resource_name
	
	return snapshot


func load_snapshot( p_snapshot: Dictionary ) -> Error:
	
	var err := OK
	
	if "resource_name" in p_snapshot:
		resource_name = p_snapshot["resource_name"]
	
	return err


func _get_filename() -> String:
	
	return resource_path.get_file().get_basename()
