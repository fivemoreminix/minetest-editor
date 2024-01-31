extends Node3D


var dragging = false
var sensitivity = 2.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	pass
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#dragging = event.pressed
	#elif dragging and event is InputEventMouseMotion:
		#var helper: Node3D = $RotationHelper
		#var cube: Node3D = $RotationHelper/Cube
		#var delta = get_process_delta_time()
		#cube.rotate_y(event.relative.x * sensitivity * delta)
		#cube.rotate_x(event.relative.y * sensitivity * delta)
