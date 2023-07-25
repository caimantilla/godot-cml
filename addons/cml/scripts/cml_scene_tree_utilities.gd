@tool
class_name CML_SceneTreeUtilities
extends RefCounted





static func get_nodes_recursively( origin_node: Node, include_internal: bool = false ) -> Array [Node]:
	
	var nodes: Array [Node] = []
	
	if not is_instance_valid( origin_node ):
		return nodes
	
	for node in origin_node.get_children( include_internal ):
		nodes.append( node )
		nodes.append_array( get_nodes_recursively(node, include_internal) )
	
	return nodes




static func save_tree_snapshot( origin_node: Node ) -> Array [Dictionary]:
	
	var node_snapshots: Array [Dictionary] = []
	
	var nodes: Array [Node] = get_nodes_recursively( origin_node, false )
	
	for node in nodes:
		if node.has_method( &"save_snapshot" ) \
		and node.has_method( &"load_snapshot" ):
			
			var node_name := String( node.name )
			var node_parent_path := String( origin_node.get_path_to(node.get_parent(), false) )
			var node_snapshot := node.save_snapshot() as Dictionary
			var node_scene_file_path := node.scene_file_path
			var node_script := node.get_script() as Script
			var node_class := node.get_class()
			
			var node_data: Dictionary = {
				"name": node_name,
				"parent_path": node_parent_path,
				"snapshot": node_snapshot,
				"scene_file_path": node_scene_file_path,
				"script": node_script.resource_path if is_instance_valid( node_script ) else "",
				"class": node_class,
			}
			
			node_snapshots.append( node_data )
	
	return node_snapshots


class _LoadedNode:
	extends Object
	
	var snapshot: Dictionary = {}
	var node: Node = null


static func load_tree_snapshot( origin_node: Node, node_snapshots: Array [Dictionary] ) -> Error:
	
	var err := OK
	
	# Nodes are first instantiated if needed, and put into this list.
	# After all nodes are ready, their state is loaded.
	var loaded_nodes: Array [_LoadedNode] = []
	
	for node_data in node_snapshots:
		
		var node: Node
		
		var node_scene_file_path := node_data["scene_file_path"] as String
		var node_script_path := node_data["script"] as String
		var node_class_name := node_data["class"] as String
		
		var node_name := node_data["name"] as StringName
		var node_parent_path := NodePath(node_data["parent_path"] as String)
		var node_snapshot := node_data["snapshot"] as Dictionary
		
		
		# Okay, the parent needs to exist to actually be able to add it to the scene tree.
		if not origin_node.has_node( node_parent_path ):
			print("Node parent doesn't exist.")
			continue
		
		var node_parent := origin_node.get_node( node_parent_path )
		
		# In the case that it already exists as part of the scene, nothing needs to be done.
		if node_parent.has_node( node_name as String ):
			node = node_parent.get_node( node_name as String )
		
		# The next option after that would be instantiating a PackedScene/
		elif ResourceLoader.exists( node_scene_file_path, "PackedScene" ):
			
			var node_packed_scene := ResourceLoader.load( node_scene_file_path, "PackedScene" ) as PackedScene
			
			if not node_packed_scene.can_instantiate():
				print( "Couldn't instantiate the PackedScene." )
				err = ERR_INVALID_DATA
				continue
			
			var node_potentially_valid_instance := node_packed_scene.instantiate( PackedScene.GEN_EDIT_STATE_DISABLED )
			if not node_potentially_valid_instance.has_method( &"load_snapshot" ):
				print( "Instantiated node doesn't implement the \"load_snapshot\" method." )
				node_potentially_valid_instance.queue_free()
				err = ERR_INVALID_DATA
				continue
			
			node = node_potentially_valid_instance
		
		# If that fails, let's try instantiating the script.
		# This will only work with script types that implement new (so, GDScript and C#).
		elif ResourceLoader.exists( node_script_path, "Script" ):
			
			var node_script := ResourceLoader.load( node_script_path, "Script" ) as Script
			
			if not node_script.has_method( &"new" ):
				print( "The node script doesn't implement the new method." )
				err = ERR_INVALID_DATA
				continue
			
			var node_potentially_valid_instance := node_script.new() as Object
			
			if not node_potentially_valid_instance is Node:
				print( "Non-node type instantiated by the script." )
				err = ERR_INVALID_DATA
				
				if node_potentially_valid_instance is Object \
				and not node_potentially_valid_instance is RefCounted:
					node_potentially_valid_instance.free()
				
				continue
			
			if not node_potentially_valid_instance.has_method( &"load_snapshot" ):
				print( "Instantiated node doesn't implement the \"load_snapshot\" method." )
				node_potentially_valid_instance.queue_free()
				err = ERR_INVALID_DATA
				continue
			
			node = node_potentially_valid_instance as Node
		
		# Finally, if not even the script exists, the saved node might extend a native class.
		# Handle this case last.
		elif ClassDB.class_exists( node_class_name ):
			
			var node_potentially_valid_instance = ClassDB.instantiate( node_class_name )
			
			if not node_potentially_valid_instance is Node:
				print( "Non-node type instantiated from class %s." % node_class_name )
				err = ERR_INVALID_DATA
				
				if node_potentially_valid_instance is Object \
				and not node_potentially_valid_instance is RefCounted:
					node_potentially_valid_instance.free()
				
				continue
			
			if not node_potentially_valid_instance.has_method( &"load_snapshot" ):
				print( "Instantiated node doesn't implement the \"load_snapshot\" method." )
				node_potentially_valid_instance.queue_free()
				err = ERR_INVALID_DATA
				continue
			
			node = node_potentially_valid_instance as Node
		
		if is_instance_valid( node ):
			
			node.name = node_name
			node_parent.add_child( node )
			
			var loaded_node := _LoadedNode.new()
			loaded_node.node = node
			loaded_node.snapshot = node_snapshot
			
			loaded_nodes.append( loaded_node )
	
	# With every node now in the tree and ready to go, it's time to actually load the tree state.
	for loaded_node in loaded_nodes:
		
		var node := loaded_node.node
		var snapshot := loaded_node.snapshot
		
		node.load_snapshot( snapshot )
	
	return err
