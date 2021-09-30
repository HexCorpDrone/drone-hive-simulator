extends Spatial

onready var drone = get_node("../Drone")
onready var slots = get_node("Slots")
onready var cursor = get_node("Cursor")
var distance_between_slots: float = 1
onready var total_slots: int = 0
var inventory_index: int = 0
var cursor_target: Vector3 = Vector3(0,0,0)
var highlighted_object = null

# Variables for inventory slot oscilation
var wiggle: bool = true # If true, slots will oscilate.
var time: float = 0 # Increases every frame for use in sin()
var magnitude: float = 0.10 # How much up and down the slots wiggle

func _process(delta):
	
	slots.translation = drone.translation + Vector3(0,2.4,0)
	
	if wiggle:
		for i in range(0, total_slots):
			slots.get_child(i).translation.y = sin(time + (i*2)) * magnitude
			time += 0.03
		if time > 360:
			time = 0
			
	if slots.visible or highlighted_object:
		cursor.visible = true
	else:
		cursor.visible = false
		
	# Set cursor target
	if highlighted_object:
		cursor_target = highlighted_object.transform.origin + highlighted_object.cursor_offset
	else:
		cursor_target = slots.get_child(inventory_index).translation + slots.translation + Vector3(0,1,0)
	
	#if slots.visible:
	cursor.translation = lerp(cursor.translation, cursor_target, 0.2 if highlighted_object else 0.5)
	#else:
	#	cursor.translation = cursor_target

func _ready():
	
	$Timer.connect("timeout",self,"inventory_timeout")
	$Timer.start()
	
	total_slots = len(slots.get_children())
	# Calculate how far back slots should start being placed so the drone is the midpoint.
	var slot_translation = distance_between_slots * - (total_slots/2)
	
	# If even amount of slots, offset by half the distance so the middle
	# slot is still directly above the drone.
	if total_slots % 2 == 0:
		slot_translation += (distance_between_slots/2)
	for slot in slots.get_children():
		slot.translation = Vector3(slot_translation, 0, 0)
		slot_translation += distance_between_slots
	update_cursor()
	
func change_selected_slot(desired_index):
	slots.visible = true
	if desired_index < 0 or desired_index > total_slots - 1:
		return
	inventory_index = desired_index
	$Timer.start(3)
	update_cursor()

func update_cursor():
	cursor.material_override.albedo_color = slots.get_child(inventory_index).material_override.albedo_color
	cursor.material_override.albedo_color.a = 1

func add_slot():
	print("Unimplemented")
	return

func inventory_timeout():
	slots.visible = false
