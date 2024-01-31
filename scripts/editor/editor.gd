extends TabContainer

signal resource_modified(resource: Resource)


func edit(resource: Resource) -> void:
	if resource is ProjectNode:
		var node_editor = preload("res://ui/editor/node_editor.tscn").instantiate()
		node_editor.resource = resource
		_add_tab(node_editor)
	else:
		var label = Label.new()
		label.name = resource.resource_path.get_file()
		label.text = "Editor not yet implemented for this resource."
		_add_tab(label)


func _add_tab(control):
	var idx = get_tab_count()
	add_child(control)
	# Add a close button
	set_tab_button_icon(idx, preload("res://icons/xmark-white.svg"))
	set_current_tab(idx)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_tab_button_pressed(tab):
	pass # TODO: close tab and save resource
