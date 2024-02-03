extends Node3D

signal selection_changed(face: MeshInstance3D, face_index: int)


@export var select_material: Material
@export_node_path("Node") var _orbit_controls_p
@onready var orbit_controls = get_node(_orbit_controls_p)
@export_node_path("Timer") var _click_timer_p
@onready var click_timer: Timer = get_node(_click_timer_p)


var _selected_face: MeshInstance3D = null:
	set(value):
		if _selected_face:
			_selected_face.material_overlay = null
		if value:
			value.material_overlay = select_material
		
		if _selected_face != value:
			var face_index = -1
			if value:
				face_index = value.get_parent().get_face_index(value)
			selection_changed.emit(value, face_index)
		
		_selected_face = value


func _raycast_2d_viewport_pos(pos: Vector2) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var cam = get_viewport().get_camera_3d()
	
	var origin = cam.project_ray_origin(pos)
	var end = origin + cam.project_ray_normal(pos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	
	return space_state.intersect_ray(query)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed: # Prevent stopping timer on release
			
			# The OrbitControls node uses a click and drag event system
			# to rotate the view, but we don't want to deselect an object
			# when rotating.
			click_timer.set_meta("position", event.position)
			click_timer.set_meta("travel", 0.0)
			click_timer.start()
		if not event.pressed and not click_timer.is_stopped():
			# The click press and released happened before the timer stopped.
			var pos = click_timer.get_meta("position")
			var result = _raycast_2d_viewport_pos(pos)
			if "collider" in result and result.collider:
				var face = result.collider.get_parent() as MeshInstance3D
				assert(face)
				_selected_face = face
			else:
				_selected_face = null
	elif event is InputEventMouseMotion:
		if not (click_timer.paused or click_timer.is_stopped()):
			var travel = click_timer.get_meta("travel")
			travel += event.relative.length()
			
			# Allow for a small amount of movement to still count a click
			if travel >= 2:
				click_timer.stop()
			else:
				click_timer.set_meta("travel", travel)
	else:
		click_timer.stop()
