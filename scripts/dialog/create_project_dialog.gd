extends ConfirmationDialog


enum {
	OK,
	WARNING,
	ERROR
}

@export_color_no_alpha var error_color
@export_color_no_alpha var warning_color

@onready var project_name = $VBoxContainer/VBoxContainer/HBoxContainer/ProjectName
@onready var project_path = $VBoxContainer/VBoxContainer/HBoxContainer2/ProjectPath
@onready var error_label = $VBoxContainer/VBoxContainer/ErrorLabel
@onready var project_type = $VBoxContainer/VBoxContainer2/ProjectType
@onready var create_folder = $VBoxContainer/VBoxContainer/HBoxContainer/CreateFolder


func get_project_name():
	return project_name.text


func get_project_path():
	return project_path.text


func get_project_type():
	if project_type.get_selected_id() == 0:
		return Project.Mod.new()
	else:
		return Project.Game.new()


func _status(status: int, text: String) -> void:
	error_label.text = text
	get_ok_button().disabled = false
	if status == WARNING:
		error_label.add_theme_color_override("font_color", warning_color)
	elif status == ERROR:
		error_label.add_theme_color_override("font_color", error_color)
		get_ok_button().disabled = true


func _test_name():
	if not Project.is_valid_identifier(project_name.text):
		create_folder.disabled = true
		_status(ERROR, "Mod and Game names may contain only letters, numbers, and underscores.")
		return
	
	# _test_name succeeded
	create_folder.disabled = false
	_status(OK, "")
	_test_path() # Update the error label to whatever _test_path() wants


func _test_path():
	var path = project_path.text
	var dir = DirAccess.open(path)
	if dir:
		var is_dir_empty = true
		
		dir.list_dir_begin()
		var file = dir.get_next()
		while not file.is_empty():
			if not file.begins_with("."):
				# Allow `.`, `..` (reserved current/parent folder names)
				# and hidden files/folders to be present.
				# For instance, this lets users initialize a Git repository
				# and still be able to create a project in the directory afterwards.
				is_dir_empty = false;
				break;
			file = dir.get_next();
		dir.list_dir_end()
		
		if not is_dir_empty:
			if dir.file_exists(Project.Mod.FILENAME) or dir.file_exists(Project.Game.FILENAME):
				_status(ERROR, "A project already exists in this directory. Choose another path or use Create Folder.")
				return
			
			if path == OS.get_environment("HOME") or path == OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS):
				_status(ERROR, "A project cannot be created in this directory. Choose another path or use Create Folder.")
				return
			
			_status(WARNING, "Warning: The chosen directory is not empty, but you can still create a project.")
		else:
			_status(OK, "")
	else:
		_status(ERROR, "The current path is not a directory.")


# Called when the node enters the scene tree for the first time.
func _ready():
	project_path.text = OS.get_environment("HOME")
	_test_name() # _test_name() calls _test_path() if it succeeds.


func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		_test_name()


func _on_create_folder_pressed():
	var dir = DirAccess.open(project_path.text)
	if dir:
		if dir.make_dir(project_name.text) == OK:
			project_path.text += '/' + project_name.text
			_test_path()


func _on_browse_pressed():
	var dialog = FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.current_dir = project_path.text
	dialog.dir_selected.connect(func(dir):
		project_path.text = dir
		_test_path()
	)
	add_child(dialog)
	dialog.popup_centered_ratio()
