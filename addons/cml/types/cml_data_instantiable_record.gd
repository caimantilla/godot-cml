@tool
class_name CML_DataInstantiableRecord
extends CML_DataRecord
## A record which can be instantiated while holding reference to the original.
## Good for when easily-manageable data should be tightly paired with instance logic.



var _base_record: CML_DataInstantiableRecord = null


func get_base_record() -> CML_DataInstantiableRecord:
	
	return _base_record


func is_an_instance() -> bool:
	
	return is_instance_valid(_base_record)


func is_an_instance_of_record(of_record: CML_DataInstantiableRecord) -> bool:
	
	if not is_an_instance():
		return false
	
	return _base_record == of_record


func instantiate() -> CML_DataInstantiableRecord:
	
	if is_an_instance():
		printerr("Can't instantiate instances. The instance will return itself.")
		return self
	
	var instance := duplicate( _do_instances_duplicate_deeply() ) as CML_DataInstantiableRecord
	instance._base_record = self
	
	return instance


func save_snapshot() -> Dictionary:
	
	assert( is_an_instance(), "Only instances can be saved." )
	
	var snapshot: Dictionary = {}
	
	snapshot["_base_record"] = _base_record.resource_path
	
	return snapshot


func load_snapshot(snapshot: Dictionary) -> Error:
	
	var err := OK
	
	return err


static func instantiate_snapshot(snapshot: Dictionary) -> CML_DataInstantiableRecord:
	
	var instance: CML_DataInstantiableRecord = null
	
	var base_record_path := snapshot["_base_record"] as String
	
	if ResourceLoader.exists( base_record_path ):
		var base_record := ResourceLoader.load( base_record_path ) as CML_DataInstantiableRecord
		instance = base_record.instantiate()
		
		if instance.load_snapshot(snapshot) != OK:
			instance = null
	
	return instance


static func _do_instances_duplicate_deeply() -> bool:
	
	return false
