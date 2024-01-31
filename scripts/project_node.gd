class_name ProjectNode
extends Resource

@export var name: String:
	set(value):
		assert(Project.is_valid_identifier(value))
		name = value
@export var description: String = ""
@export var use_six_textures: bool = false
@export var textures: Array[String] = []


func get_hidden_inspector_properties():
	return ["textures"]


func _init():
	pass
