class_name ProjectNode
extends Resource

@export var name: String

func _init(name):
	assert(Project.is_valid_identifier(name))
	self.name = name
