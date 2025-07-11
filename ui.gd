extends CanvasLayer

func update_lives_display(lives : int):
	$LivesLabel.text = "Lives: %d" % lives  
	
func show_game_over_screen():
	$GameOverLabel.visible=true
