extends Spatial

onready var floors = get_node("Floor")
onready var walls = get_node("Walls")
onready var intern_corners = get_node("InternalCorners")
onready var extern_corners = get_node("ExternalCorners")

var floor_positions: Array = []

func add_floor(pos: Vector3):
	floors.multimesh.instance_count += 1
	floor_positions.append(pos)
	
func add_wall(pos):
	return
	
func add_intern_corner(pos):
	return
	
func add_extern_corner(pos):
	return

func init_multimeshes():
	for i in range(len(floor_positions)):
		floors.multimesh.set_instance_transform(i, Transform(Basis(), floor_positions[i]))