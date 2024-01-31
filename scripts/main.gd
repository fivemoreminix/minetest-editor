extends Control


@export_node_path("MenuBar") var menu_bar_path
@onready var menu_bar: MenuBar = get_node(menu_bar_path)
@export_node_path("Tree") var file_tree_path
@onready var file_tree: Tree = get_node(file_tree_path)
@export_node_path("Control") var inspector_path
@onready var inspector: Control = get_node(inspector_path)


func open_dir(dir: String) -> void:
	file_tree.open_dir(dir)
	EditorGlobal.add_recent_project(dir)


# Called when the node enters the scene tree for the first time.
func _ready():
	# Configure the "Open Recents" option in File to show a submenu
	menu_bar.get_node("File").set_item_submenu(2, "RecentsMenu")


func _on_menubar_file_id_pressed(id):
	match id:
		0: # Open Folder
			var dialog = $FileDialog
			dialog.access = FileDialog.ACCESS_FILESYSTEM
			dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
			dialog.dir_selected.connect(func(dir):
				open_dir(dir)
			)
			dialog.popup_centered_ratio()
		1: # New Project
			var dialog = $CreateProjectDialog
			dialog.confirmed.connect(func():
				var project_type = dialog.get_project_type()
				if project_type is Project.Mod or project_type is Project.ModPack:
					project_type.name = dialog.get_project_name()
				elif project_type is Project.Game:
					project_type.title = dialog.get_project_name()
				else:
					assert(false, "unreachable")
				
				var project = Project.create(dialog.get_project_path(), project_type)
				open_dir(project.dir)
			)
			dialog.popup_centered_ratio()
		_: pass


func _on_file_system_resource_opened(resource):
	inspector.edit(resource)


func _on_recents_menu_about_to_popup():
	var menu = menu_bar.get_node("File/RecentsMenu") as PopupMenu
	assert(menu != null)
	for i in range(menu.item_count):
		menu.remove_item(0) # Items get shifted up
	
	var recents = EditorGlobal.get_settings().recents
	for i in range(recents.size()):
		menu.add_item("{0} {1}".format([i+1, recents[i]]))
	
	menu.add_separator("", 776)
	menu.add_item("Clear Recents", 777) # Positive karma?


func _on_recents_menu_id_pressed(id):
	if id == 777:
		EditorGlobal.get_settings().recents.clear()
		return
	
	var dir = EditorGlobal.get_settings().recents[id]
	open_dir(dir)
