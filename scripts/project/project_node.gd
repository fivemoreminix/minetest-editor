class_name ProjectNode
extends ProjectItem


# https://api.minetest.net/definition-tables/#node-definition
# (extends all of the properties of ProjectItem)

# https://api.minetest.net/nodes/#node-drawtypes
@export_enum("normal", "airlike", "liquid", "flowingliquid", "glasslike", "glasslike_framed", \
	"glasslike_framed_optional", "allfaces", "allfaces_optional", "torchlike", "signlike", \
	"plantlike", "firelike", "fencelike", "raillike", "nodebox", "mesh", "plantlike_rooted")
var drawtype: String = "normal" # TODO: implement various drawtypes editing

@export var use_six_textures: bool = false
@export var tiles: Array[String] = []

# TODO: The default is "opaque" for drawtypes normal, liquid and flowingliquid, mesh and nodebox; or "clip" otherwise.
@export_enum("opaque", "clip", "blend")
var use_texture_alpha: String

## If true, sunlight will pass through this node.
@export var sunlight_propogates: bool = false
## If true, objects and characters collide with this node.
@export var walkable: bool = true

## If false, the node can never be dug.
@export var diggable: bool = true
## If true, can be climbed on like a ladder.
@export var climbable: bool = false
## The higher the value, the more this node slows down the movement of players.
@export_range(0, 7) var move_resistance: int = 0

# TODO: implement "sounds" property as a @export_section("Sounds") with each sub-property
# being one of the sounds.

## Name of item dropped when the node is dug. Leaving this empty drops the node itself.
@export var drop: String = "" # TODO: implement the more complex variant of this property


func get_hidden_inspector_properties() -> PackedStringArray:
	var arr = super.get_hidden_inspector_properties()
	arr.append_array(PackedStringArray(["tiles"]))
	return arr


func _init():
	pass
