class_name Enemy

extends CharacterBody2D

var animations
var timer
var speed
var ray
var bulletSpeed
var damage
var shootFrame
var enemyPos 
var bulletPath
var canShoot = false
var hasShot = true

func play_shoot_animations():
	if timer.is_stopped() && canShoot && !checkWalls():
		hasShot = false
		if global_position.x < Global.playerPos.x:
			animations.set_flip_h(false)
		else:
			animations.set_flip_h(true)
		animations.play("shootRight")
		timer.start()

func process(_delta, parent):
	if checkFrame() && !hasShot && !checkWalls():
		hasShot = true
		shoot(parent)
	enemyPos = (Global.playerPos - global_position).normalized()
	velocity = global_position.direction_to(Global.playerPos)
	if animations.is_playing && animations.animation != "moveRight" && animations.animation != "idle" && global_position.distance_to(Global.playerPos) < 200:
		return
	move(_delta, parent)

func move(delta, parent):
	if global_position.x < Global.playerPos.x:
		animations.set_flip_h(false)
	else:
		animations.set_flip_h(true)
	animations.play("moveRight")
	parent.move_and_collide(velocity * speed * delta)

func shoot(parent):
	var bullet = bulletPath.instantiate()
	var right_side = parent.get_node("rightSide")
	var left_side = parent.get_node("leftSide")

	if animations.is_flipped_h() == false:
		bullet.position = parent.get_node("rightSide").position
	else:
		bullet.position = parent.get_node("leftSide").position
	parent.add_child(bullet)

func checkFrame():
	if animations.frame == shootFrame:
		return true
	return false

func resetAnimation():
	if animations.is_playing() && animations.animation == 'shootRight':
		animations.stop()
		animations.play("moveRight")

func checkWalls():
	ray.target_position = Global.playerPos
	if ray.get_collider():
		resetAnimation()
		return true
	return false
