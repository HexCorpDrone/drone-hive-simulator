extends StaticBody

onready var entry_src = load("res://objects/Elevator.tscn")

func _ready():
	$Area.connect("body_entered",self,"body_entered")
	
func body_entered(body):
	if body.name == "Drone":
		get_tree().get_root().get_node("Main/Viewport/Game").new_level()
		var entry = entry_src.instance()
		entry.transform = transform
		get_tree().get_root().get_node("Main/Viewport/Game").add_child(entry)
		entry.name = "Elevator"
		queue_free()
