extends CanvasLayer


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")


func _on_quit_pressed() -> void:
	get_tree().guit() 
