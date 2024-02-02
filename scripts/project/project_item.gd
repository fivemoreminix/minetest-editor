class_name ProjectItem
extends Resource


# https://api.minetest.net/definition-tables/#item-definition
## A unique identifier. Must contain only letters A-Z
@export var name: String:
	set(value):
		assert(Project.is_valid_identifier(value))
		name = value
@export var description: String = ""

@export var groups: Groups
class Groups:
	extends Resource
	# https://wiki.minetest.net/Groups
	# used by crafting recipes
	@export_range(1, 3) var wood: int
	@export_range(1, 3) var stone: int
	@export_range(1, 3) var sand: int
	@export_range(1, 3) var flora: int
	@export_range(1, 3) var leaves: int
	# determine damage and digging time
	@export_range(1, 3) var oddly_breakable_by_hand: int
	@export_range(1, 3) var crumbly: int
	@export_range(1, 3) var cracky: int
	@export_range(1, 3) var choppy: int
	@export_range(1, 3) var fleshy: int
	@export_range(1, 3) var snappy: int
	@export_range(1, 3) var explody: int
	# special groups
	@export_range(1, 3) var dig_immediate: int
	@export_range(1, 3) var soil: int

@export var inventory_image: String


func get_hidden_inspector_properties() -> PackedStringArray:
	return PackedStringArray([])
