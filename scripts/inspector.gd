extends Panel

signal resource_modified(resource: Resource)


@export_node_path("VBoxContainer") var container_path
@onready var container: VBoxContainer = get_node(container_path)


var _resource: Resource = null


func edit(resource: Resource) -> void:
	_clear()
	
	if not resource:
		var label = Label.new()
		label.text = "No resource selected."
		container.add_child(label)
		return
	
	# Allows Resources to hide properties from the inspector window, but still
	# save them to disk.
	var hidden_properties = []
	if resource.has_method("get_hidden_inspector_properties"):
		hidden_properties = resource.get_hidden_inspector_properties()
	
	_resource = resource
	for property in resource.get_property_list():
		if property.name in hidden_properties:
			continue
		
		var p_name = property.name
		var p_hint = property.hint
		var p_classname = property.class_name
		var p_type = property.type # @GlobalScope.Variant.Type
		var p_usage = property.usage
		
		# Only view properties that are declared in the script and exported
		if p_usage & PROPERTY_USAGE_SCRIPT_VARIABLE == 0 or \
			p_usage & PROPERTY_USAGE_STORAGE == 0:
			continue
		
		var label = Label.new()
		label.text = p_name.capitalize() + ":"
		label.tooltip_text = p_name
		container.add_child(label)
		
		# If the property's underlying type is a class, we skip it
		if p_classname != "":
			continue
		
		match p_type:
			TYPE_BOOL:
				var check = CheckBox.new()
				check.name = p_name
				check.text = "On"
				check.button_pressed = resource.get(p_name)
				check.toggled.connect(func(new_value): _on_property_updated(p_name, new_value))
				container.add_child(_background(check))
				check.set_anchors_preset(PRESET_HCENTER_WIDE)
			TYPE_STRING:
				var input = LineEdit.new()
				input.name = p_name
				input.text = resource.get(p_name)
				input.clear_button_enabled = true
				input.custom_minimum_size.y = 36
				input.text_submitted.connect(func(new_value): _on_property_updated(p_name, new_value))
				container.add_child(input)
			_:
				var l = Label.new()
				l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				l.text = "(Property type has not been implemented.)"
				container.add_child(l)
				push_error("Property type has not been implemented.")


func get_resource():
	return _resource


"""
_background creates a Panel with an alternate background as the parent of
the provided `child` control.
"""
func _background(child: Control) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size.y = 36
	child.custom_minimum_size.y = 36
	panel.add_theme_stylebox_override("panel", preload("res://theme/panel_accentuated.tres"))
	panel.add_child(child)
	child.set_anchors_preset(PRESET_FULL_RECT)
	return panel


func _clear():
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


# Called when the node enters the scene tree for the first time.
func _ready():
	edit(null)


func _on_property_updated(property_name, new_value):
	_resource.set(property_name, new_value)
	resource_modified.emit(_resource)
