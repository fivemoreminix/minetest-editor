class_name InputNameDialog
extends ConfirmationDialog

"""
input_submitted gets emitted when the user enters an input
that passes validation and clicks the OK button.
"""
signal input_submitted(input: String)

enum {
	VALIDATOR_NONE,
	VALIDATOR_FILE,
	VALIDATOR_ID
}

@export_node_path("TextEdit") var input_path
@onready var input = get_node(input_path)
@export_node_path("Label") var error_label_path
@onready var error_label = get_node(error_label_path)

var validator = VALIDATOR_NONE


"""
varargs get passed along on signal emit.
"""
func reset(validator, default_input="", title="Confirm", accept="OK"):
	self.validator = validator
	input.text = default_input
	self.title = title
	get_ok_button().text = accept
	
	if validator == VALIDATOR_NONE:
		error_label.text = ""
		get_ok_button().disabled = false
	else:
		validate()


func validate():
	match validator:
		VALIDATOR_NONE:
			pass
		VALIDATOR_FILE:
			push_error("Not yet implemented!") # TODO
		VALIDATOR_ID:
			if Project.is_valid_identifier(input.text):
				error_label.text = ""
				get_ok_button().disabled = false
			else:
				error_label.text = "A valid name contains only letters, numbers, and underscores."
				get_ok_button().disabled = true
		_: push_error("Invalid value for validator")


func _on_text_edit_text_changed():
	validate()


func _on_confirmed():
	input_submitted.emit(input.text)
