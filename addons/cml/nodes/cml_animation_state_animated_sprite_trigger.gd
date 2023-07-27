@tool
class_name CML_AnimationState_AnimatedSpriteTrigger
extends CML_AnimationState


var DIRECTION_PROPERTY_MAP = {}


@export_node_path var animated_sprite_path := NodePath()
@export_node_path( "AnimationPlayer" ) var animation_player_path := NodePath()

## Unimplemented.
@export var retain_frame_when_switching_direction := false

@export var restart_if_triggered_while_active := false

var default_direction = 0:
	set( value ):
		default_direction = value
		if _current_direction == null:
			_current_direction = default_direction

var _current_direction = null

var _directional_properties = {}


func _set( property, value ):
	
	if property in _directional_properties:
		_directional_properties[property] = value
		return true


func _get( property ):
	
	if property in _directional_properties:
		return _directional_properties[property]


func _notification( what ):
	
	match what:
		
		NOTIFICATION_EDITOR_PRE_SAVE:
			if is_active():
				var sprite = get_animated_sprite()
				if sprite:
					sprite.frame = 0
		
		NOTIFICATION_EDITOR_POST_SAVE:
			if is_active():
				_sprite_update()


func _get_property_list():
	
	var properties = []
	
	properties.append(
		{
			"type": TYPE_INT,
			"name": "default_direction",
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join( Direction.keys() ),
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		}
	)
	
	for key in Direction:
		properties.append(
			{
				"type": TYPE_STRING_NAME,
				"name": "%s_animation_name" % key,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			}
		)
	
	for key in Direction:
		properties.append(
			{
				"type": TYPE_BOOL,
				"name": "flip_%s" % key,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			}
		)
	
	return properties


func get_animated_sprite() -> Node:
	
	if has_node( animated_sprite_path ):
		var node = get_node( animated_sprite_path )
		if node is AnimatedSprite3D or node is AnimatedSprite2D:
			return node
	return null


func get_animation_player() -> AnimationPlayer:
	
	if has_node( animation_player_path ):
		var node = get_node( animation_player_path )
		if node is AnimationPlayer:
			return node
	return null


func _trigger():
	
	if not restart_if_triggered_while_active:
		if is_active():
			return
	
	_sprite_update()
	_animation_player_update()


func set_animation_speed( p_speed_multiplier: float ):
	
	var sprite = get_animated_sprite()
	if sprite:
		sprite.speed_scale = p_speed_multiplier
	
	var player = get_animation_player()
	if player:
		player.speed_scale = p_speed_multiplier


func set_direction( p_direction ):
	
	_current_direction = p_direction
	if is_active():
		_sprite_update()


func _sprite_update():
	
	var sprite = get_animated_sprite()
	if not sprite:
		return
	
	if not _current_direction in DIRECTION_PROPERTY_MAP:
		return
	
	var params = DIRECTION_PROPERTY_MAP[_current_direction]
	
	sprite.flip_h = get( params["flip"] )
	sprite.animation = get( params["animation"] )
#	if Engine.is_editor_hint() and get_tree().edited_scene_root == self or get_tree().edited_scene_root == owner:
#		return
	sprite.play()


func _animation_player_update():
	
	var player = get_animation_player()
	if not player:
		return
	
	if player.current_animation == name and player.is_playing():
		return
	
	if player.has_animation( name ):
		player.play( name )
	else:
		player.stop()


func set_direction_enum( p_direction_enum ):
	
	super( p_direction_enum )
	
	DIRECTION_PROPERTY_MAP.clear()
	
	for key in Direction:
		var value = Direction[key]
		var animation_key = &"%s_animation_name" % key
		var flip_key = &"flip_%s" % key
		DIRECTION_PROPERTY_MAP[value] = { "animation": animation_key, "flip": flip_key }
		
		if not animation_key in _directional_properties:
			_directional_properties[animation_key] = &""
		
		if not flip_key in _directional_properties:
			_directional_properties[flip_key] = false
