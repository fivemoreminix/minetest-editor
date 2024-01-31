extends Node


const FILEPATH = "user://editor_settings.tres"


var _settings: EditorGlobalSettings = null


func get_settings() -> EditorGlobalSettings:
	return _settings


func add_recent_project(path: String) -> void:
	if _settings:
		if path in _settings.recents:
			_settings.recents.erase(path)
		
		_settings.recents.insert(0, path)
		if _settings.recents.size() >= _settings.limit_recents:
			_settings.recents.resize(_settings.limit_recents)


func _enter_tree():
	if FileAccess.file_exists(FILEPATH):
		_settings = load(FILEPATH)
	else:
		_settings = load("res://default_editor_settings.tres")


func _exit_tree():
	if _settings:
		if ResourceSaver.save(_settings, FILEPATH) != OK:
			push_error("Failed to save editor settings resource")
