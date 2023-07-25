@tool
class_name CML_FilesystemUtilities
extends RefCounted


static func get_files_in_dir( directory: String, recursive: bool, filter_extensions := PackedStringArray() ) -> PackedStringArray:
	
	var list := PackedStringArray()
	
	if recursive:
		_get_files_recursive( directory, list )
	else:
		_get_files_single_level( directory, list )
	
	
	if not filter_extensions.is_empty():
		
		var indices_to_erase := PackedInt64Array()
		for i in list.size():
			var filepath: String = list[i]
			var extension: String = filepath.get_extension()
			if not extension in filter_extensions:
				indices_to_erase.push_back( i )
		
		for i in range( indices_to_erase.size() - 1, -1, -1 ):
			var index_to_erase: int = indices_to_erase[i]
			list.remove_at( index_to_erase )
	
	return list


static func get_resources_of_type( type: Variant, directory: String, recursive: bool, filter_extensions := PackedStringArray() ) -> Array:
	
	var file_paths := get_files_in_dir( directory, recursive, filter_extensions )
	var resources = []
	
	for path in file_paths:
		if ResourceLoader.exists( path ):
			var resource = ResourceLoader.load( path )
			if is_instance_of( resource, type ):
				resources.append( resource )
	
	return resources




static func ensure_directory_exists( directory: String ) -> bool:
	
	var dir = DirAccess.open( "res://" )
	
	if not dir:
		print_debug( "wtf?" )
		return false
	
	if not dir.dir_exists( directory ):
		dir.make_dir_recursive( directory )
	
	return dir.dir_exists( directory )



static func check_file_exists( filepath: String ) -> bool:
	
	return FileAccess.file_exists( filepath )



static func _get_files_single_level( target_directory: String, list: PackedStringArray ) -> void:
	
	var dir := DirAccess.open( target_directory )
	if not dir:
		print_debug( "Folder %s doens't exist." % target_directory )
		return
	
	dir.include_hidden = false
	dir.include_navigational = false
	
	dir.list_dir_begin()
	var filename: String = dir.get_next()
	while not filename.is_empty():
		var joined: String = target_directory.path_join( filename )
		if not dir.current_is_dir():
			list.push_back( joined )
		filename = dir.get_next()
	dir.list_dir_end()
	
	return


static func _get_files_recursive( current_directory: String, file_list: PackedStringArray ) -> void:
	
	var dir := DirAccess.open( current_directory )
	if not dir:
		print_debug( "Folder %s doesn't exist." % current_directory )
		return
	
	dir.include_hidden = false
	dir.include_navigational = false
	
	dir.list_dir_begin()
	var filename: String = dir.get_next()
	while not filename.is_empty():
		var joined: String = current_directory.path_join( filename )
		if dir.current_is_dir():
			_get_files_recursive( joined, file_list )
		else:
			file_list.push_back( joined )
		filename = dir.get_next()
	dir.list_dir_end()
