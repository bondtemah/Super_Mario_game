extends CharacterBody2D

var SPEED = -25.0
var facing_left = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_alive =  true

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	add_to_group("Enemy")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if !$RayCast2D.is_colliding() && is_on_floor():
		flip()
	
	# Set the horizontal velocity to a constant negative value to move left.
	velocity.x = -SPEED
	
	update_animation()
	move_and_slide()

func update_animation():
	animated_sprite_2d.play("hop")


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.velocity.y=-270
		is_alive = false
		queue_free()
		
func flip():
	facing_left = !facing_left
	scale.x = abs(scale.x) * -1
	if facing_left:
		SPEED = abs(SPEED)
	else:
		SPEED = abs(SPEED) * -1	
		
		
		
		
