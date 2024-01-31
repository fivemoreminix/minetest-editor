extends Control


@export_node_path("Tree") var file_tree_path
@onready var file_tree = get_node(file_tree_path)
@export_node_path("Control") var inspector_path
@onready var inspector = get_node(inspector_path)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_menubar_file_id_pressed(id):
	match id:
		0: # Open Folder
			var dialog = $FileDialog
			dialog.access = FileDialog.ACCESS_FILESYSTEM
			dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
			dialog.dir_selected.connect(func(dir):
				file_tree.open_dir(dir)
			)
			dialog.popup_centered_ratio()
		1: # New Project
			var dialog = $CreateProjectDialog
			dialog.confirmed.connect(func():
				var project = Project.create(dialog.get_project_path(), dialog.get_project_name(), dialog.get_project_kind())
				file_tree.open_dir(project.dir)
			)
			dialog.popup_centered_ratio()
		_: pass


func _on_file_system_resource_opened(resource):
	inspector.edit(resource)
