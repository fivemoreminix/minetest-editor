extends Node3D


var drawtype: String = "normal":
	set(value):
		match value:
			"normal": pass
			_:
				push_error("unsupported drawtype: " + value)


@export var tiles: Array[Texture2D]: # Default texture set in properties
	set(value):
		var faces = get_faces()
		var i = 0
		while i < faces.size():
			var quad: QuadMesh = faces.mesh
			
			# Material is a Resource which is reference counted, we can
			# make duplicates and if an old material is no longer needed
			# it just gets freed.
			var new_mat: Material = quad.material.duplicate()
			quad.material = new_mat
			
			var tiles_i = min(i, value.size()-1)
			new_mat.albedo_texture = tiles[tiles_i]


"""
get_faces returns an array of the MeshInstance3D QuadMesh faces
of the node, in the order that the "tiles" property applies to them.
"""
func get_faces() -> Array[MeshInstance3D]:
	var faces: Array[MeshInstance3D] = []
	for i in range(get_child_count()):
		var child = get_child(i) as MeshInstance3D
		assert(child, 'Child "{0}" is not a MeshInstance3D'.format([child.name]))
		faces.append(child)
	return faces


"""
get_face_index returns the child/face/tile index for the given
mesh instance. Returns -1 if the mesh is not a child of this node.
"""
func get_face_index(face: MeshInstance3D) -> int:
	for i in range(get_child_count()):
		if get_child(i) == face:
			return i
	return -1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
