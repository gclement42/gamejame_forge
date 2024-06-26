extends Node2D

var card
var onShop = false
var mouseOn = false
var isStored = false
var forChoose = false
var isSelected = false
var animationsFinished: Array
var dropableZoneName
var init_scale: Vector2

@onready var rectLabel = $Control
@onready var labelName = $Control/ColorRect2/name
@onready var animationPlayer = $Card/AnimationPlayer
@onready var animatesExplosions = $AnimatesExplosions
var initPos

func _ready():
	self.scale = Vector2(0.6, 0.6)
	init_scale = self.scale
	rectLabel.visible = false
	self.input_pickable = true

func handleClick():
	if Input.is_action_just_pressed("LeftClick") and Global.playerIsInForge and mouseOn:
		get_tree().call_group("Forge", "add_to_dropable", self)
	if Input.is_action_just_pressed("LeftClick") and forChoose and mouseOn:
		isSelected = true
	if Input.is_action_just_pressed("LeftClick") and self.card.type == "consumable" and  not forChoose and not Global.playerIsInForge:
		use_card()
	if Input.is_action_just_pressed("RightClick") and mouseOn:
		delete_card()
	
func _process(delta):
	if not animationPlayer.is_playing() and not animatesExplosions.is_playing():
		if Global.cardMouseOn == self:
			handleClick()
	if not self.card.animation.is_empty():
		$Card/AnimationPlayer.play(self.card.animation)
		self.card.animation = ""
func display_description():
	labelName.text = card.name
	for i in card.level:
		var starSprite = $Control/ColorRect2/Level.duplicate()
		starSprite.position.x += starSprite.get_rect().size.x * i
		$Control/ColorRect2.add_child(starSprite)
	var i = 1
	for key in card.effects:
		if key != "empty":
			var rectEffect = rectLabel.find_child("Effect" + str(i))
			var skillIcon = rectEffect.find_child("Skillicon")
			var label = rectEffect.find_child("Label")
			skillIcon.texture = load("res://Assets/Interface/Skillicon_" +  key + ".png")
			label.text = str(card.effects[key])
			rectEffect.visible = true
			i += 1
		else:
			$Control/Description.visible = true
			$Control/Description/Label.text = self.card.description
	

func _on_mouse_entered():
	if Global.cardMouseOn and Global.cardMouseOn != self:
		Global.cardMouseOn.hidden_description()
	elif Global.cardMouseOn == self:
		return
	Global.cardMouseOn = self
	mouseOn = true
	rectLabel.visible = true
	display_description()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.3).set_ease(Tween.EASE_IN)
	if self.card.type == "consumable":
		$Control/ClickForUse.visible = true
		$Control/ClickForUse.play("default")
	self.z_index = 100
	
func forge_animation(cardInitPos):
	initPos = cardInitPos
	animationPlayer.play("Intro")
	
func remove_card_from_forge():
	self.isStored = false
	
func hidden_description():
	Global.cardMouseOn = null
	mouseOn = false
	rectLabel.visible = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", init_scale, 0.3).set_ease(Tween.EASE_IN)
	if self.card.type == "consumable":
		$Control/ClickForUse.stop()
	self.z_index = 11
	

func _on_mouse_exited():
	hidden_description()

func _on_animation_player_animation_finished(anim_name):
	animationsFinished.append(anim_name)
	var tween = get_tree().create_tween()
	if initPos and anim_name == "Intro":
		tween.tween_property(self, "position", Vector2(initPos.x, initPos.y), 0.2).set_ease(Tween.EASE_OUT)
		tween.tween_callback(Global.player.gui.display_cards)
		tween.tween_callback(self.queue_free)
		

func _on_tween_completed():
	self.queue_free()
	
func destroy_card():
	var tween = get_tree().create_tween()
	tween.tween_property($Card, "scale", Vector2(0.1, 0.1), 0.3).set_ease(Tween.EASE_IN)
	animatesExplosions.visible = true
	animatesExplosions.play("vortex")


func _on_animates_explosions_animation_finished():
	animationsFinished.append(animatesExplosions.animation)
	#if animatesExplosions.animation == "vortex":
		#self.queue_free()
		
func _on_animates_explosions_frame_changed():
	if animatesExplosions.animation == "vortex" and animatesExplosions.frame == 14:
		$Card.visible = false


func use_card():
	Global.cardMouseOn = null
	self.card.applyEffects(Global.player)
	Global.player.remove_card(self.card)
	Global.player.gui.display_life(Global.player)
	self.queue_free()


func delete_card():
	Global.cardMouseOn = null
	Global.player.remove_card(self.card)
	destroy_card()
	Global.player.gui.actualize_gui()
