extends Tree


var cwd = OS.get_user_data_dir()

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
				branch.collapsed = true # Don't show everything all at once
				add_to_treeitem_from_dir_recursive(branch, file_path)
			else:
				branch.set_icon(0, preload("res://icons/page-white.svg"))
			
			file_name = dir.get_next()
	else:
		printerr("FileTree: Failed to open the new CWD")
		print_stack()


func open_dir(dir):
	clear() # Reset the tree
	
	self.cwd = dir
	var root = create_item() # root hidden
	
	var branch = create_item(root)
	branch.set_icon_max_width(0, 18)
	branch.set_text(0, dir.get_file())
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
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_item_mouse_selected(position, mouse_button_index):
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		$PopupMenu.show()
		$PopupMenu.position = position


func _on_right_click_menu_id_pressed(id):
	match id:
		0: # Open
			item_activated.emit()
		1: # Copy Path (relative to parent project or CWD)
			# For now taking a shortcut and just getting the path relative to the CWD
			DisplayServer.clipboard_set(get_selected().get_meta("path_relative"))
		2: # Rename
			edit_selected(true) # see _on_item_edited()
		3: # Delete
			DirAccess.remove_absolute(get_selected().get_meta("path"))
			get_selected().free()
		4: # Duplicate
			pass
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
