extends KinematicGravity
class_name Drone

signal shutdown_complete

onready var icon_display: Sprite3D = get_node("Display/Icon")
onready var id_display: Spatial = get_node("Display/ID")
onready var display_container: Spatial = get_node("Display")
onready var sprite: AnimatedSprite3D = get_node("Body")

onready var sfx: AudioStreamPlayer = get_node("SFX")
onready var shutdown: AudioStream = load("res:/sfx/shutdown3.ogg")
onready var sfx_battery: AudioStream = load("res://sfx/battery.ogg")

onready var inventory = get_node("../Inventory")

onready var pickup_area = get_node("PickupArea")
onready var interact_area = get_node("InteractArea")

onready var item_drop = get_node("ItemDrop")

var id: String = "0000"
var headbob_offset: Vector2 = Vector2(2.4, 2.3) #y if head is dipped, else x.
var speed: float = 5

var immobile: bool = false

var move_up = 1
var move_down = 2
var move_left = 4
var move_right = 8
var inventory_left = 16
var inventory_right = 32
var interact = 64

func _ready():
	sfx.connect("finished", self, "sfx_complete")
	$FaceTimer.connect("timeout", self, "show_id")
	interact_area.connect("body_entered", self, "object_entered_interaction_range")
	interact_area.connect("body_exited", self, "object_left_interaction_range")
	set_id("0052")
	gravity = 5
	
func set_id(new_id: String):
	if int(id) > 9999 or int(id) < 0:
		return
	id = new_id
	id_display.get_node("ID1").frame = int(id.substr(0,1))
	id_display.get_node("ID2").frame = int(id.substr(1,1))
	id_display.get_node("ID3").frame = int(id.substr(2,1))
	id_display.get_node("ID4").frame = int(id.substr(3,1))
	
func toggle_face():
	if icon_display.visible == true:
		show_id()
	else:
		show_icon()

func show_id():
	icon_display.visible = false
	id_display.visible = true
	
func show_icon():
	icon_display.visible = true
	id_display.visible = false

func toggle_display():
	display_container.visible = !display_container.visible
	
func get_inputs() -> int:
	
	if immobile:
		return 0
	
	var inputs = 0
	
	if Input.is_action_pressed("move_left"):
		inputs += move_left
	if Input.is_action_pressed("move_right"):
		inputs += move_right
	if Input.is_action_pressed("move_up"):
		inputs += move_up
	if Input.is_action_pressed("move_down"):
		inputs += move_down
	
	if Input.is_action_just_pressed("inventory_left"):
		inventory.change_selected_slot(inventory.inventory_index - 1)
	elif Input.is_action_just_pressed("inventory_right"):
		inventory.change_selected_slot(inventory.inventory_index + 1)
	if Input.is_action_just_pressed("interact"):
		interact_with_object()
	elif Input.is_action_just_pressed("inventory_cancel"):
		inventory.change_selected_slot(inventory.inventory_index)
	return inputs

func _process(delta):
	
	if immobile:
		sprite.animation = "forward"
		sprite.playing = false
		sprite.frame = 0
		#display_container.translation.y = headbob_offset.y
		display_container.visible = true
		return
	
	velocity = Vector3(0,0,0)
	
	# Get inputs, set velocity
	var inputs = get_inputs()
	
	if inputs & move_right:
		velocity.x = 1 * speed
		sprite.flip_h = false
		display_container.translation = Vector3(0.05,2.4,0.15)
		interact_area.rotation_degrees.y = 0
		item_drop.translation.x = 3
	if inputs & move_left:
		velocity.x = -1 * speed
		sprite.flip_h = true
		display_container.translation = Vector3(-0.5,2.4,0.15)
		interact_area.rotation_degrees.y = 180
		item_drop.translation.x = -3
	if inputs & move_down:
		velocity.z = 1 * speed
		interact_area.rotation_degrees.y = 270
	if inputs & move_up:
		velocity.z = -1 * speed
		interact_area.rotation_degrees.y = 90

	# Check if drone should keep walking.
	sprite.playing = !(not inputs and (sprite.frame == 0 or sprite.frame == 2))

	# Calculate headbob
	if sprite.frame % 2 != 0:
		display_container.translation.y = headbob_offset.y
	else:
		display_container.translation.y = headbob_offset.x
		
	#if velocity.z < 0:
	#	sprite.animation = "backward"
	#else:
	#	sprite.animation = "forward"
		
	#if sprite.animation == "backward":
	#	display_container.visible = false
	#else:
	#	display_container.visible = true
		
func interact_with_object():
	
	var body = inventory.highlighted_object

	if body == null:
		if inventory.primed == true:
			inventory.drop_item()
		else:
			inventory.prime_item()
	elif body is Interactable and body.interactable:
		if inventory.primed == true:
			# if inventory item ready, attempt use on object
			inventory.use_item_on(body)
			return
		else:
			# if no inventory item ready, use normally

			body.interact(self)
			if !(body is Pickup) and body.interactable:
				# Bounce cursor and play sound when interacting with interactable.
				inventory.sfx_confirm.play(0)
				inventory.cursor.translation += Vector3(0,0.5,0)
			return



func game_over_1():
	print("Drone game over")
	show_icon()
	icon_display.frame = 1
	sfx.stream = shutdown
	sfx.play()
	sprite.playing = false
	sprite.frame = 0

func game_over_2():
	sprite.playing = true
	icon_display.frame = 3

func sfx_complete():
	if sfx.stream == shutdown:
		print("Drone shutdown complete, emitting signal.")
		emit_signal("shutdown_complete")
		
func recharge():
	sfx.stream = sfx_battery
	sfx.play()
	$BatteryParticles.one_shot = false
	$BatteryParticles.emitting = true
	$BatteryParticles.one_shot = true
	icon_display.frame = 3
	show_icon()
	$FaceTimer.start()	

func object_entered_interaction_range(body):
	if body is Interactable and body.interactable:
		inventory.highlighted_object = body
		print("marking as interactable: " + str(body.name))
		if !inventory.slots.visible:
			inventory.cursor.translation = inventory.highlighted_object.transform.origin + inventory.highlighted_object.cursor_offset
		
func object_left_interaction_range(body):
	if inventory.highlighted_object != null and body.name == inventory.highlighted_object.name:
		inventory.highlighted_object = null
