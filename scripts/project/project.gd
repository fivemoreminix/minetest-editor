class_name Project
extends Resource


class ProjectType:
	extends Resource

class Game:
	extends ProjectType
	const FILENAME = "mtegame.tres"
	# https://api.minetest.net/games/
	@export var title: String = "" # Human-readable, not identifier
	@export var description: String = ""
	@export var author: String = ""
	@export var allowed_mapgens: Array[String]
	@export var disallowed_mapgens: Array[String]
	@export var disallowed_mapgen_settings: Array[String]
	@export var disabled_settings: Array[String]
	@export var map_persistent: bool = true

class Mod:
	extends ProjectType
	const FILENAME = "mtemod.tres"
	# https://api.minetest.net/mods/#modconf
	@export var name: String = ""
	@export var description: String = ""
	@export var depends: Array[String] = []
	@export var optional_depends: Array[String] = []
	@export var author: String = ""
	@export var title: String = ""

class ModPack:
	extends ProjectType
	const FILENAME = "mtemodpack.tres"
	# https://api.minetest.net/mods/#modpacks
	@export var name: String = ""
	@export var description: String = ""
	@export var author: String = ""
	@export var title: String = ""


@export var type: ProjectType = null

var dir: String


# Little note to anyone working with Resources: the _init()
# of all project resources must not contain arguments because
# the engine will not be able to instantiate the class
# when loading the .tscn file. See Object documentation.
func _init():
	pass


static func is_valid_identifier(text) -> bool:
	return not text.is_empty() and text.is_valid_identifier()


"""
open reads an existing project file configuration at file_path.

file_path must be an absolute path to the Project resource.

Returns null if file_path does not contain a valid config.
"""
static func open(file_path: String) -> Project:
	if ResourceLoader.exists(file_path):
		var project = load(file_path)
		project.dir = file_path.get_base_dir()
		return project
	return null


"""
create initializes a directory with the given project name.
This does not create the containing directory; the files are
created inside `dir`.

dir is the path of an empty directory.

kind contains all of the data about the type of project.
"""
static func create(dir: String, type: ProjectType) -> Project:
	var project = Project.new()
	project.type = type
	project.dir = dir
	project.save()
	return project


func save():
	assert(type != null)
	ResourceSaver.save(self, dir + '/' + type.FILENAME)
