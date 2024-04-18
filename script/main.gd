extends Node2D
@onready var invetory_menu = $Player/Camera2D/InventoryMenu
@onready var Player = $Player.player
var pause = true
var card_manager


# Called when the node enters the scene tree for the first time.
func _ready():
	var card_manager_scene = preload("res://cardsManager.tscn")
	card_manager = card_manager_scene.instantiate()
	add_child(card_manager)
	invetory_menu.hide()
	
func _process(_delta):
	if Input.is_action_just_pressed("Inventory"):
		invetoryMenu()
	if Global.playerIsDead == true:
		get_tree().change_scene_to_file("res://GameOver.tscn")
		
func invetoryMenu():
	if !pause:
		invetory_menu.hide()
		invetory_menu.close()
		Engine.time_scale = 1
		pause = true
	else:
		invetory_menu.show()
		invetory_menu.open(Player)
		Engine.time_scale = 0
		pause = false
