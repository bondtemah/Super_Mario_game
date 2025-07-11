extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.is_restart=false
	$AudioWorld.play()
	
	var player = $TileMap/player
	
	# Обновим UI при старте (чтобы LivesLabel был актуален)
	$UI.update_lives_display(player.lives)
	
	$TileMap/player.connect("life_lost", Callable($UI, "update_lives_display"))
	$TileMap/player.connect("game_over", Callable($UI, "show_game_over_screen"))
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.is_restart: 
		$AudioWorld.stop()

func _on_interact_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.die()

func show_game_over_screen():
	await get_tree().create_timer(1.0).timeout  # Подождать немного после смерти
	# Скрыть только LivesLabel
	$UI/LivesLabel.visible = false
	
	# Показать GameOver
	$UI/GameOverLabel.visible = true


func _on_transition_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://underworld.tscn")
