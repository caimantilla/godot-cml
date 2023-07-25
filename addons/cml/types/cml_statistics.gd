@tool
class_name CML_Statistics
extends Resource
## Base class for numerical stat storage.


enum ABSTRACT_ENUMERATION {}

const ABSTRACT_INT: int = 0
const ABSTRACT_STRING_ARRAY: PackedStringArray = []


func _init() -> void:
	
	_refresh_name()


func serialize() -> Dictionary:
	
	var data: Dictionary = {}
	
	for stat_key in get_stat_property_keys():
		data[stat_key] = get( stat_key )
	
	return data


func deserialize(data: Dictionary) -> Error:
	
	var err: Error = OK
	
	for stat_key in get_stat_property_keys():
		if stat_key in data:
			set( stat_key, data[stat_key] )
		else:
			err = ERR_INVALID_DATA
	
	return err


## Used to save the stats for a saved game.
func save_snapshot() -> Dictionary:
	
	# Switch to storing as PackedInt32Array eventually
	return serialize()


## Used to load the stats from a saved game.
func load_snapshot(data: Dictionary) -> Error:
	
	# Switch to loading from an array eventually
	return deserialize( data )



static func stat_exists(id: int) -> bool:
	
	var stat_count := get_stat_count()
	
	return id > -1 and id < stat_count



static func get_stat_enumeration() -> Dictionary:
	
	return ABSTRACT_ENUMERATION


## Returns the number of stats that this object holds.
static func get_stat_count() -> int:
	
	return ABSTRACT_INT


## Returns the keys to access the stats of this object.
static func get_stat_property_keys() -> PackedStringArray:
	
	return ABSTRACT_STRING_ARRAY


## Returns the full name of each stat.
static func get_stat_names() -> PackedStringArray:
	
	return ABSTRACT_STRING_ARRAY


## Returns the abbreviation of each stat.
static func get_stat_abbreviations() -> PackedStringArray:
	
	return ABSTRACT_STRING_ARRAY


static func get_property_keys_as_component() -> Dictionary:
	
	var component_keys: Dictionary = {}
	
	for key in get_stat_property_keys():
		component_keys[key] = true
	
	return component_keys


## Assigns a name based on the stats.
## Useful for editing stats in the inspector.
func _refresh_name() -> void:
	
	# Refreshing the name in-game could hurt performance, so maybe only do it in-editor.
	# ALTHOUGH, I'll do some tests later. It probably wouldn't matter.
#	if not Engine.is_editor_hint():
#		return
	
	var _temp_name := ""
	
	var stat_count = get_stat_count()
	var stat_property_keys = get_stat_property_keys()
	var stat_abbreviations = get_stat_abbreviations()
	
	for i in stat_count:
		
		var stat_property_key = stat_property_keys[i]
		var stat_abbreviation = stat_abbreviations[i]
		
		var stat_value = get( stat_property_key )
		
		_temp_name += "%s: %s" % [ stat_abbreviation, str(stat_value) ]
		
		if i != stat_count - 1:
			_temp_name += ", "
	
	resource_name = _temp_name
