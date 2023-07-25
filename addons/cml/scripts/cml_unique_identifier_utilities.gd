@tool
class_name CML_UniqueIdentifierUtilities
extends RefCounted


const UID_DEFAULT_LENGTH: int = 6


const ALPHANUMERIC_CHARACTER_SET: Array [String] = [
	
	'A',
	'B',
	'C',
	'D',
	'E',
	'F',
	'G',
	'H',
	'I',
	'J',
	'K',
	'L',
	'M',
	'N',
	'O',
	'P',
	'Q',
	'R',
	'S',
	'T',
	'U',
	'V',
	'W',
	'X',
	'Y',
	'Z',
	
	'0',
	'1',
	'2',
	'3',
	'4',
	'5',
	'6',
	'7',
	'8',
	'9',
	
]


static func generate_alphanumeric_id( length: int = UID_DEFAULT_LENGTH, blacklist: Dictionary = {} ) -> String:
	
	const MAX_ATTEMPTS: int = 512
	
	for i in MAX_ATTEMPTS:
		
		var id: String
		
		for j in length:
			id += ALPHANUMERIC_CHARACTER_SET.pick_random()
		
		if blacklist.has( id ):
			continue
		
		return id
	
	printerr( "Could not manage to generate a unique alphanumeric ID within %d attempts." % MAX_ATTEMPTS )
	return ""
