class_name Project
extends Resource

const MOD_FILENAME = "mtemod.tres"
const GAME_FILENAME = "mtegame.tres"

const PROJECT_GAME = "Game"
const PROJECT_MOD = "Mod"

var dir: String
@export var name: String
@export var kind: String


func _init(name, kind):
	self.name = name
	self.kind = kind


static func is_valid_identifier(text) -> bool:
	return not text.is_empty() and text.is_valid_identifier()


"""
open reads an existing project file configuration at file_path.

file_path must be an absolute path to the Project resource.

Returns null if file_path does not contain a valid config.
"""
static func open(file_path) -> Project:
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
name should include only A-z 0-9 and underscores.
kind is PROJECT_GAME or PROJECT_MOD.
"""
static func create(dir, name, kind) -> Project:
	var project = Project.new(name, kind)
	project.dir = dir
	project.save()
	return project


func save():
	var file_name = MOD_FILENAME if kind == PROJECT_MOD else GAME_FILENAME
	ResourceSaver.save(self, dir + '/' + file_name)
