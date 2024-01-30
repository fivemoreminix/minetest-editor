extends Tree

signal resource_opened(resource: Resource)


enum {
	TYPE_FILE,
	TYPE_DIR,
}


# Right click contextual menus
@export_node_path("PopupMenu") var item_menu_path
@onready var item_menu: PopupMenu = get_node(item_menu_path)
@export_node_path("PopupMenu") var multi_menu_path
@onready var multi_menu: PopupMenu = get_node(multi_menu_path)
@export_node_path("PopupMenu") var dir_menu_path
@onready var dir_menu: PopupMenu = get_node(dir_menu_path)

# Dialogs
@export_node_path("InputNameDialog") var input_name_dialog_path
@onready var input_name_dialog: InputNameDialog = get_node(input_name_dialog_path)


var cwd = OS.get_user_data_dir()
var visible_root: TreeItem

func add_to_treeitem_from_dir_recursive(parent, path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var relative_path = parent.get_meta("path_relative", "")
			if relative_path.is_empty():
				relative_path = file_name
			else:
				relative_path += '/' + file_name
			
			var file_path = path+'/'+file_name
			
			var branch = create_item(parent)
			branch.set_icon_max_width(0, 18)
			branch.set_text(0, file_name)
			branch.set_meta("path", file_path)
			branch.set_meta("path_relative", relative_path)
			branch.set_tooltip_text(0, relative_path)
			
			if dir.current_is_dir():
				branch.set_icon(0, preload("res://icons/folder-white.svg"))
				branch.set_meta("type", TYPE_DIR)
				branch.collapsed = true # Don't show everything all at once
				add_to_treeitem_from_dir_recursive(branch, file_path)
			else:
				branch.set_meta("type", TYPE_FILE)
				branch.set_icon(0, preload("res://icons/page-white.svg"))
			
			file_name = dir.get_next()
	else:
		push_error("FileTree: Failed to open the new CWD")
		print_stack()


"""
get_item_by_path returns the TreeItem by its absolute path.

Returns null if the path does not match a TreeItem.
"""
func get_item_by_path(path: String) -> TreeItem:
	var path_parts = path.split("/", false)
	# Skip parts until the value at i = root name
	var i = 0
	while i < len(path_parts):
		var name = path_parts[i]
		i += 1 # Increments before the break so that i != root name
		if name == visible_root.get_text(0):
			break
	
	# Root was not found, this path is not inside our workspace
	if i >= len(path_parts):
		return null
	
	# i = index of the child name in the root
	var n = visible_root
	while i < len(path_parts):
		var name = path_parts[i]
		
		# Visit each child of n, to select a new n
		var child_count = n.get_child_count()
		var found = false
		for j in range(child_count):
			var child = n.get_child(j)
			if child.get_text(0) == name:
				n = child
				found = true
				break
		
		if not found:
			return null
		
		i += 1
	
	return n


func is_multi_selected():
	var item = get_next_selected(null)
	if item == null or get_next_selected(item) == null: return false
	return true


func open_dir(dir):
	clear() # Reset the tree
	
	self.cwd = dir
	var root = create_item() # root hidden
	
	var branch = create_item(root)
	visible_root = branch
	branch.set_icon_max_width(0, 18)
	branch.set_text(0, dir.get_file())
	branch.set_meta("path", dir)
	branch.set_meta("path_relative", ".")
	branch.set_meta("type", TYPE_DIR)
	branch.set_tooltip_text(0, dir) # Tooltip is the full path
	
	var d = DirAccess.open(dir)
	if d:
		if d.file_exists(Project.MOD_FILENAME):
			branch.set_icon(0, preload("res://icons/settings-white.svg"))
		elif d.file_exists(Project.GAME_FILENAME):
			branch.set_icon(0, preload("res://icons/settings-white.svg"))
		else:
			branch.set_icon(0, preload("res://icons/folder-white.svg"))
	else:
		branch.set_icon(0, preload("res://icons/folder-white.svg"))
		
	add_to_treeitem_from_dir_recursive(branch, dir)


func _ready():
	dir_menu.set_item_submenu(0, "CreateNewSubMenu")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_item_mouse_selected(position, mouse_button_index):
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		var menu
		if is_multi_selected():
			menu = multi_menu
		elif get_selected().get_meta("type") == TYPE_DIR:
			menu = dir_menu
		else:
			menu = item_menu
		menu.show()
		menu.position = position


func _on_item_popup_menu_id_pressed(id):
	match id:
		0: # Open
			item_activated.emit()
		1: # Copy Path (relative to parent project or CWD)
			# For now taking a shortcut and just getting the path relative to the CWD
			DisplayServer.clipboard_set(get_selected().get_meta("path_relative"))
		2: # Rename
			edit_selected(true) # see _on_item_edited()
		3: # Delete
			OS.move_to_trash(get_selected().get_meta("path"))
			get_selected().free()
		4: # Duplicate
			OS.alert("Duplicate has not been implemented yet!\n\nDuplicate files outside of the editor.")
		_: pass


func _on_multi_popup_menu_id_pressed(id):
	match id: # TODO: implement multi select right click menu
		_: pass


func _on_dir_popup_menu_id_pressed(id):
	match id:
		1: # Expand/Collapse directory
			get_selected().collapsed = not get_selected().collapsed
		2: # Copy Path
			DisplayServer.clipboard_set(get_selected().get_meta("path_relative"))
		3: # Rename
			edit_selected(true)
		4: # Duplicate
			# TODO: implement duplicate function
			OS.alert("Duplicate has not been implemented yet!\n\nDuplicate directories outside of the editor.")
		5: # Delete
			OS.move_to_trash(get_selected().get_meta("path"))
			get_selected().free()
		_: pass


func _on_dir_create_new_submenu_id_pressed(id):
	match id:
		0: # Lua Script
			input_name_dialog.reset(InputNameDialog.VALIDATOR_ID, "", "Create Script", "Lua")
			input_name_dialog.popup_centered()
		1: # Node
			input_name_dialog.reset(InputNameDialog.VALIDATOR_ID, "", "Create Node", "ProjectNode")
			input_name_dialog.popup_centered()
		2: # Craft
			input_name_dialog.reset(InputNameDialog.VALIDATOR_ID, "", "Create Craft", "ProjectCraft")
			input_name_dialog.popup_centered()
		_: pass


# Called when a file has been renamed
func _on_item_edited():
	var item = get_selected()
	var base_dir = item.get_meta("path").get_base_dir()
	var old_path = item.get_meta("path")
	var new_path = base_dir + '/' + item.get_text(0)
	DirAccess.rename_absolute(old_path, new_path)
	# We have to update the item's meta data
	item.set_meta("path", new_path)
	item.set_meta("path_relative", item.get_meta("path_relative").get_base_dir() + '/' + new_path.get_file())


func _on_timer_timeout():
	pass # TODO: Refresh the file system for changes


func _on_input_name_dialog_input_submitted(input, varargs):
	# A single argument as a String representing the type of Resource to create
	if len(varargs) == 1:
		var resource
		match varargs[0]:
			"ProjectNode":
				resource = ProjectNode.new(input)
			_:
				push_error("Resource type not implemented")
				return
		
		var path = get_selected().get_meta("path") + '/' + input + '.tres'
		if ResourceSaver.save(resource, path) != OK:
			push_error("Failed to create resource", resource, path)
		open_dir(cwd) # Refresh file system to show new file
		var item = get_item_by_path(path)
		set_selected(item, 0)
		resource_opened.emit(resource)
