extends CharacterBody2D

signal life_lost(lives)
signal game_over

var lives = 3
var is_jumping = false
var is_dying = false
var is_invulnerable = false
const INVULNERABILITY_TIME = 1.5
const SPEED = 180.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var audio_player = $AnimatedSprite2D/AudioPlayer

func _ready():
	add_to_group("Player")
	emit_signal("life_lost", lives)

func _physics_process(delta):
	if is_dying:
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_animation(direction)
	move_and_slide()

func update_animation(direction):
	if is_dying:
		return
	if is_jumping:
		animated_sprite_2d.play("jump")
	elif direction != 0:
		animated_sprite_2d.flip_h = (direction < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and body.is_alive:
		take_damage()

func take_damage():
	if is_dying or is_invulnerable:
		return

	lives -= 1

	if lives > 0:
		emit_signal("life_lost", lives)
		start_invulnerability()
		knockback_flash()
	else:
		emit_signal("game_over")
		die()

func start_invulnerability():
	is_invulnerable = true
	set_collision_with_enemies(false)
	await get_tree().create_timer(INVULNERABILITY_TIME).timeout
	set_collision_with_enemies(true)
	is_invulnerable = false
	animated_sprite_2d.modulate = Color(1, 1, 1)

func set_collision_with_enemies(enabled: bool):
	# отключаем столкновение с врагами на 2-м слое
	if enabled:
		collision_mask |= 1 << 1  # включить 2-й бит
	else:
		collision_mask &= ~(1 << 1)  # выключить 2-й бит

func knockback_flash():
	for i in range(5):
		animated_sprite_2d.modulate.a = 0.2
		await get_tree().create_timer(0.1).timeout
		animated_sprite_2d.modulate.a = 1.0
		await get_tree().create_timer(0.1).timeout

func die():
	if is_dying:
		return

	is_dying = true
	audio_player.play()
	animated_sprite_2d.play("die")
	emit_signal("game_over")
	await move_player_up_and_down()
	
	await get_tree().create_timer(1.5).timeout

	get_tree().change_scene_to_file("res://gameover.tscn")


func move_player_up_and_down():
	var start_position = position
	var up_position = start_position + Vector2(0, -100)
	var down_position = start_position + Vector2(0, 600)

	while position.y > up_position.y:
		position.y -= 4
		await get_tree().create_timer(0.01).timeout

	while position.y < down_position.y:
		position.y += 4
		await get_tree().create_timer(0.01).timeout
