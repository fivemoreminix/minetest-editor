extends ConfirmationDialog


@onready var project_name = $VBoxContainer/VBoxContainer/HBoxContainer/ProjectName
@onready var project_path = $VBoxContainer/VBoxContainer/HBoxContainer2/ProjectPath
@onready var error_label = $VBoxContainer/VBoxContainer/ErrorLabel
@onready var project_kind = $VBoxContainer/VBoxContainer2/ProjectKind
@onready var create_folder = $VBoxContainer/VBoxContainer/HBoxContainer/CreateFolder


func get_project_name():
	return project_name.text


func get_project_path():
	return project_path.text


func get_project_kind():
	if project_kind.get_selected_id() == 0:
		return Project.PROJECT_MOD
	else:
		return Project.PROJECT_GAME


func _test_name():
	if not Project.is_valid_identifier(project_name.text):
		create_folder.disabled = true
		get_ok_button().disabled = true
		
		error_label.text = "Mod and Game names may contain only letters, numbers, and underscores."
		return
	
	# _test_name succeeded
	create_folder.disabled = false
	get_ok_button().disabled = false
	_test_path() # Update the error label to whatever _test_path() wants


func _test_path():
	var path = project_path.text
	var dir = DirAccess.open(path)
	if dir:
		var is_dir_empty = false
		
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
			if dir.file_exists(Project.MOD_FILENAME) or dir.file_exists(Project.GAME_FILENAME):
				get_ok_button().disabled = true
				error_label.text = "A project already exists in this directory. Choose another path or use Create Folder."
				return
			
			if path == OS.get_environment("HOME") or path == OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS):
				get_ok_button().disabled = true
				error_label.text = "A project cannot be created in this directory. Choose another path or use Create Folder."
				return
			
			get_ok_button().disabled = false
			error_label.text = "Warning: The chosen directory is not empty, but you can still create a project."
		
		get_ok_button().disabled = false
		error_label.text = ""
	else:
		get_ok_button().disabled = true
		error_label.text = "The current path is not a directory."


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
