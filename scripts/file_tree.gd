extends Tree


var cwd = OS.get_user_data_dir()

func add_to_treeitem_from_dir_recursive(parent, path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var file_path = path+'/'+file_name
			
			var branch = create_item(parent)
			branch.set_icon_max_width(0, 18)
			branch.set_text(0, file_name)
			branch.set_meta("path", file_path)
			branch.set_tooltip_text(0, file_path)
			
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
